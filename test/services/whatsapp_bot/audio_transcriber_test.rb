# frozen_string_literal: true

require "test_helper"

class WhatsappBot::AudioTranscriberTest < ActiveSupport::TestCase
  setup do
    @user = users(:active_user)
    
    # Setup app settings
    AppSetting.instance.update!(
      openai_api_key: "sk-test-key",
      openai_model: "gpt-4",
      unipile_dsn: "https://api.unipile.com:13211",
      unipile_api_key: "test-key",
      unipile_account_id: "test-account"
    )
    
    @transcriber = WhatsappBot::AudioTranscriber.new
  end

  # ==========================================
  # Transcription Tests
  # ==========================================

  test "transcribes audio message successfully" do
    message = create_audio_message(attachment_id: "att_123")
    
    stub_attachment_download("att_123", "fake audio data", "audio/ogg")
    stub_whisper_transcription("Bonjour, je voudrais un devis", "fr")
    
    result = @transcriber.transcribe(message)
    
    assert_equal "Bonjour, je voudrais un devis", result[:transcription]
    assert_equal "fr", result[:language]
    assert result[:duration_ms].is_a?(Integer)
  end

  test "transcribes Turkish audio" do
    message = create_audio_message(attachment_id: "att_456")
    
    stub_attachment_download("att_456", "fake audio data", "audio/ogg")
    stub_whisper_transcription("Merhaba, teklif istiyorum", "tr")
    
    result = @transcriber.transcribe(message)
    
    assert_equal "Merhaba, teklif istiyorum", result[:transcription]
    assert_equal "tr", result[:language]
  end

  test "handles MP3 audio format" do
    message = create_audio_message(
      attachment_id: "att_mp3",
      payload: { "attachments" => [{ "id" => "att_mp3" }] }
    )
    
    stub_attachment_download("att_mp3", "fake mp3 data", "audio/mpeg", "audio.mp3")
    stub_whisper_transcription("Test audio", "fr")
    
    result = @transcriber.transcribe(message)
    
    assert_equal "Test audio", result[:transcription]
  end

  # ==========================================
  # Validation Tests
  # ==========================================

  test "raises error for nil message" do
    error = assert_raises(WhatsappBot::AudioTranscriber::TranscriptionError) do
      @transcriber.transcribe(nil)
    end
    
    assert_match(/Message is required/, error.message)
  end

  test "raises error for non-audio message" do
    message = @user.whatsapp_messages.create!(
      unipile_message_id: "msg_text",
      direction: "inbound",
      message_type: "text",
      content: "Hello"
    )
    
    error = assert_raises(WhatsappBot::AudioTranscriber::TranscriptionError) do
      @transcriber.transcribe(message)
    end
    
    assert_match(/not an audio type/, error.message)
  end

  test "raises error if message already has transcription" do
    message = @user.whatsapp_messages.create!(
      unipile_message_id: "msg_transcribed",
      direction: "inbound",
      message_type: "audio",
      audio_transcription: "Already transcribed"
    )
    
    error = assert_raises(WhatsappBot::AudioTranscriber::TranscriptionError) do
      @transcriber.transcribe(message)
    end
    
    assert_match(/already has transcription/, error.message)
  end

  test "raises error when no attachment ID in payload" do
    message = @user.whatsapp_messages.create!(
      unipile_message_id: "msg_no_att",
      direction: "inbound",
      message_type: "audio",
      raw_payload: {}
    )
    
    error = assert_raises(WhatsappBot::AudioTranscriber::TranscriptionError) do
      @transcriber.transcribe(message)
    end
    
    assert_match(/No attachment ID/, error.message)
  end

  # ==========================================
  # Payload Extraction Tests
  # ==========================================

  test "extracts attachment_id from direct field" do
    message = create_audio_message(
      attachment_id: "att_direct",
      payload: { "attachment_id" => "att_direct" }
    )
    
    stub_attachment_download("att_direct", "audio data", "audio/ogg")
    stub_whisper_transcription("Test", "fr")
    
    result = @transcriber.transcribe(message)
    assert_not_nil result[:transcription]
  end

  test "extracts attachment_id from attachments array" do
    message = create_audio_message(
      attachment_id: "att_array",
      payload: { "attachments" => [{ "id" => "att_array" }] }
    )
    
    stub_attachment_download("att_array", "audio data", "audio/ogg")
    stub_whisper_transcription("Test", "fr")
    
    result = @transcriber.transcribe(message)
    assert_not_nil result[:transcription]
  end

  test "extracts attachment_id from media object" do
    message = create_audio_message(
      attachment_id: "att_media",
      payload: { "media" => { "id" => "att_media" } }
    )
    
    stub_attachment_download("att_media", "audio data", "audio/ogg")
    stub_whisper_transcription("Test", "fr")
    
    result = @transcriber.transcribe(message)
    assert_not_nil result[:transcription]
  end

  # ==========================================
  # Error Handling Tests
  # ==========================================

  test "raises error when attachment not found" do
    message = create_audio_message(attachment_id: "att_missing")
    
    stub_request(:get, %r{api.unipile.com.*/attachments/att_missing})
      .to_return(status: 404, body: { error: "Not found" }.to_json)
    
    error = assert_raises(WhatsappBot::AudioTranscriber::TranscriptionError) do
      @transcriber.transcribe(message)
    end
    
    assert_match(/attachment not found/, error.message)
  end

  test "raises error on download failure" do
    message = create_audio_message(attachment_id: "att_error")
    
    stub_request(:get, %r{api.unipile.com.*/attachments/att_error})
      .to_return(status: 500, body: { error: "Server error" }.to_json)
    
    error = assert_raises(WhatsappBot::AudioTranscriber::TranscriptionError) do
      @transcriber.transcribe(message)
    end
    
    assert_match(/Failed to download/, error.message)
  end

  # ==========================================
  # Direct Audio Data Transcription
  # ==========================================

  test "transcribes audio data directly" do
    stub_whisper_transcription("Direct transcription test", "fr")
    
    audio_data = {
      content: "fake audio data",
      content_type: "audio/ogg",
      filename: "audio.ogg"
    }
    
    result = @transcriber.transcribe_audio_data(audio_data)
    
    assert_equal "Direct transcription test", result[:transcription]
    assert_equal "fr", result[:language]
  end

  test "uses language hint when provided" do
    stub_whisper_transcription("Türkçe metin", "tr")
    
    audio_data = {
      content: "fake audio data",
      content_type: "audio/ogg",
      filename: "audio.ogg"
    }
    
    result = @transcriber.transcribe_audio_data(audio_data, "tr")
    
    assert_equal "tr", result[:language]
  end

  private

  def create_audio_message(attachment_id:, payload: nil)
    payload ||= { "attachment_id" => attachment_id }
    
    @user.whatsapp_messages.create!(
      unipile_message_id: "msg_#{SecureRandom.hex(4)}",
      direction: "inbound",
      message_type: "audio",
      raw_payload: payload
    )
  end

  def stub_attachment_download(attachment_id, content, content_type, filename = "audio.ogg")
    stub_request(:get, %r{api.unipile.com.*/attachments/#{attachment_id}})
      .to_return(
        status: 200,
        body: content,
        headers: {
          "Content-Type" => content_type,
          "Content-Disposition" => "attachment; filename=\"#{filename}\""
        }
      )
  end

  def stub_whisper_transcription(text, language)
    stub_request(:post, "https://api.openai.com/v1/audio/transcriptions")
      .to_return(
        status: 200,
        body: {
          "text" => text,
          "language" => language,
          "segments" => []
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end
end
