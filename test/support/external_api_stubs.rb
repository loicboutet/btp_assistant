# frozen_string_literal: true

# Helpers centralisés pour stubber les APIs externes (Unipile / OpenAI / Stripe)
# dans les tests (WebMock + Mocha).
#
# Usage:
#   include ExternalApiStubs
#   stub_openai_chat_completion(content: "OK")
#   stub_unipile_send_message
#   stub_stripe_verify_webhook(event)
#
module ExternalApiStubs
  # ------------------------
  # OpenAI (ruby-openai)
  # ------------------------
  def stub_openai_chat_completion(content: "Test response", model: "gpt-4")
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(
        status: 200,
        body: {
          "choices" => [{ "message" => { "role" => "assistant", "content" => content } }],
          "usage" => { "prompt_tokens" => 10, "completion_tokens" => 5, "total_tokens" => 15 },
          "model" => model
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_openai_whisper_transcription(text: "Transcribed audio text", language: "fr")
    stub_request(:post, "https://api.openai.com/v1/audio/transcriptions")
      .to_return(
        status: 200,
        body: { "text" => text, "language" => language }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  # ------------------------
  # Unipile (Faraday)
  # ------------------------
  def stub_unipile_send_message(dsn: "https://api.unipile.com:13211", message_id: "msg_response_123")
    stub_request(:post, %r{#{Regexp.escape(dsn)}/api/v1/chats/.*/messages})
      .to_return(
        status: 200,
        body: { message_id: message_id }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_unipile_download_attachment(dsn: "https://api.unipile.com:13211", attachment_id: "att_audio_123", body: "fake audio data", content_type: "audio/ogg", filename: "audio.ogg")
    stub_request(:get, %r{#{Regexp.escape(dsn)}/api/v1/attachments/#{Regexp.escape(attachment_id)}})
      .to_return(
        status: 200,
        body: body,
        headers: {
          "Content-Type" => content_type,
          "Content-Disposition" => "attachment; filename=\"#{filename}\""
        }
      )
  end

  # ------------------------
  # Stripe (lib Stripe) - stubbé via Mocha
  # ------------------------
  def stub_stripe_verify_webhook(event)
    StripeService.any_instance.stubs(:verify_webhook).returns(event)
  end

  def build_stripe_event(type, object_hash)
    OpenStruct.new(
      type: type,
      data: OpenStruct.new(object: OpenStruct.new(object_hash))
    )
  end

  def stripe_test_headers
    {
      'Content-Type' => 'application/json',
      'Stripe-Signature' => 'test_signature'
    }
  end
end
