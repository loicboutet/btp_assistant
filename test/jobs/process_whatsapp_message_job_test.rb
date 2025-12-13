# frozen_string_literal: true

require "test_helper"

class ProcessWhatsappMessageJobTest < ActiveJob::TestCase
  include ExternalApiStubs

  setup do
    # Use a unique phone number to avoid fixture conflicts
    @user = User.create!(
      phone_number: "+33633445566",
      company_name: "Test Company Job",
      subscription_status: "active",
      unipile_chat_id: "chat_test_123"
    )

    # Setup app settings
    AppSetting.instance.update!(
      openai_api_key: "sk-test-key",
      openai_model: "gpt-4",
      unipile_dsn: "https://api.unipile.com:13211",
      unipile_api_key: "test-key",
      unipile_account_id: "test-account"
    )

    # Stubs API externes (OpenAI + Unipile)
    stub_openai_chat_completion(content: "Test response")
    stub_openai_whisper_transcription(text: "Transcribed audio text", language: "fr")
    stub_unipile_send_message(dsn: "https://api.unipile.com:13211", message_id: "msg_response_123")
  end

  # ==========================================
  # Basic Processing Tests
  # ==========================================

  test "processes text message successfully" do
    message = create_message(message_type: "text", content: "Bonjour!")

    assert_not message.processed?

    ProcessWhatsappMessageJob.perform_now(message.id)

    message.reload
    assert message.processed?
    assert_nil message.error_message
  end

  test "processes audio message and marks for transcription" do
    # Need to stub attachment download for audio
    stub_unipile_download_attachment(
      dsn: "https://api.unipile.com:13211",
      attachment_id: "att_audio_123",
      body: "fake audio data",
      content_type: "audio/ogg",
      filename: "audio.ogg"
    )

    message = create_message(
      message_type: "audio",
      content: nil,
      raw_payload: { "attachment_id" => "att_audio_123" }
    )

    ProcessWhatsappMessageJob.perform_now(message.id)

    message.reload
    assert message.processed?
  end

  test "processes image message" do
    message = create_message(message_type: "image", content: nil)

    ProcessWhatsappMessageJob.perform_now(message.id)

    message.reload
    assert message.processed?
  end

  test "processes document message" do
    message = create_message(message_type: "document", content: nil)

    ProcessWhatsappMessageJob.perform_now(message.id)

    message.reload
    assert message.processed?
  end

  test "processes video message" do
    message = create_message(message_type: "video", content: nil)

    ProcessWhatsappMessageJob.perform_now(message.id)

    message.reload
    assert message.processed?
  end

  # ==========================================
  # Idempotency Tests
  # ==========================================

  test "skips already processed messages" do
    message = create_message(message_type: "text", content: "Test")
    message.update!(processed: true)

    # Should not raise and should not change anything
    ProcessWhatsappMessageJob.perform_now(message.id)

    message.reload
    assert message.processed?
  end

  # ==========================================
  # Error Handling Tests
  # ==========================================

  test "discards job when message not found" do
    non_existent_id = 999999

    # Should not raise, job is discarded
    assert_nothing_raised do
      ProcessWhatsappMessageJob.perform_now(non_existent_id)
    end
  end

  # ==========================================
  # System Logging Tests
  # ==========================================

  test "creates system log for processed message" do
    message = create_message(message_type: "text", content: "Test logging")

    assert_difference "SystemLog.where(event: 'whatsapp_message_processed').count", 1 do
      ProcessWhatsappMessageJob.perform_now(message.id)
    end

    log = SystemLog.where(event: "whatsapp_message_processed").last
    assert_equal @user.id, log.user_id
    assert_includes log.description, "text"
  end

  # ==========================================
  # Audio Transcription Tests
  # ==========================================

  test "audio message is marked as needing transcription before processing" do
    message = create_message(message_type: "audio", content: nil, audio_transcription: nil)

    assert message.needs_transcription?
  end

  # ==========================================
  # Queue Configuration Tests
  # ==========================================

  test "job is queued in default queue" do
    message = create_message(message_type: "text", content: "Test")

    assert_enqueued_with(queue: "default") do
      ProcessWhatsappMessageJob.perform_later(message.id)
    end
  end

  test "job has perform method" do
    assert ProcessWhatsappMessageJob.instance_methods.include?(:perform)
  end

  private

  def create_message(message_type:, content:, audio_transcription: nil, raw_payload: nil)
    WhatsappMessage.create!(
      user: @user,
      unipile_message_id: "msg_#{SecureRandom.hex(8)}",
      unipile_chat_id: "chat_#{SecureRandom.hex(4)}",
      direction: "inbound",
      message_type: message_type,
      content: content,
      audio_transcription: audio_transcription,
      raw_payload: raw_payload || { test: true },
      processed: false
    )
  end
end
