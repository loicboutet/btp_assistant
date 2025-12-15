# frozen_string_literal: true

# Audio Transcriber for WhatsApp voice messages
# Downloads audio from Unipile and transcribes using OpenAI Whisper
#
# Usage:
#   transcriber = WhatsappBot::AudioTranscriber.new
#   result = transcriber.transcribe(whatsapp_message)
#   # => { transcription: "Bonjour...", language: "fr", duration_ms: 1234 }
#
module WhatsappBot
  class AudioTranscriber
    class TranscriptionError < StandardError; end

    def initialize(unipile_client: nil, openai_client: nil)
      @unipile_client = unipile_client || UnipileClient.new
      @openai_client = openai_client || OpenaiClient.new
    end

    # Transcribe an audio WhatsApp message
    # @param whatsapp_message [WhatsappMessage] The audio message to transcribe
    # @return [Hash] { transcription: String, language: String, duration_ms: Integer }
    def transcribe(whatsapp_message)
      validate_message!(whatsapp_message)

      attachment_id = extract_attachment_id(whatsapp_message)
      raise TranscriptionError, "No attachment ID found in message" if attachment_id.blank?

      # Download audio from Unipile
      Rails.logger.info "[AudioTranscriber] Downloading audio #{attachment_id}"

      audio_data = begin
        download_audio(attachment_id)
      rescue TranscriptionError => e
        # Some Unipile WhatsApp voice notes are downloaded via message-scoped endpoint:
        #   /api/v1/messages/:message_id/attachments/:attachment_id
        msg_id = whatsapp_message.unipile_message_id
        raise e if msg_id.blank?

        Rails.logger.info "[AudioTranscriber] Fallback download via message #{msg_id} / attachment #{attachment_id}"
        @unipile_client.download_message_attachment(message_id: msg_id, attachment_id: attachment_id)
      end

      # Save to temp file and transcribe
      transcribe_audio_data(audio_data, whatsapp_message.user.preferred_language)
    end

    # Transcribe audio data directly (for testing or other sources)
    # @param audio_data [Hash] { content: binary, content_type: String, filename: String }
    # @param language_hint [String, nil] Language hint ("fr" or "tr")
    # @return [Hash] { transcription: String, language: String, duration_ms: Integer }
    def transcribe_audio_data(audio_data, language_hint = nil)
      extension = determine_extension(audio_data[:filename], audio_data[:content_type])

      Tempfile.create(["whatsapp_audio", extension]) do |temp_file|
        temp_file.binmode
        temp_file.write(audio_data[:content])
        temp_file.rewind

        Rails.logger.info "[AudioTranscriber] Transcribing #{temp_file.path} (#{File.size(temp_file.path)} bytes)"

        result = @openai_client.transcribe_audio(
          file_path: temp_file.path,
          language: language_hint
        )

        {
          transcription: result[:transcription],
          language: result[:language],
          duration_ms: result[:duration_ms]
        }
      end
    end

    private

    def validate_message!(message)
      raise TranscriptionError, "Message is required" if message.nil?
      raise TranscriptionError, "Message is not an audio type" unless message.audio?
      raise TranscriptionError, "Message already has transcription" if message.audio_transcription.present?
    end

    def extract_attachment_id(message)
      payload = message.raw_payload
      return nil if payload.blank?

      attachment = if payload["attachments"].is_a?(Array)
                     payload["attachments"].first
                   elsif payload["attachments"].is_a?(Hash)
                     payload["attachments"]
                   end

      payload["attachment_id"] || attachment&.[]( "attachment_id") || attachment&.[]("id")
    end

    def download_audio(attachment_id)
      @unipile_client.download_attachment(attachment_id: attachment_id)
    rescue UnipileClient::NotFoundError
      raise TranscriptionError, "Audio attachment not found"
    rescue UnipileClient::ApiError => e
      raise TranscriptionError, "Failed to download audio: #{e.message}"
    end

    def determine_extension(filename, content_type)
      # Try to get extension from filename
      if filename.present?
        ext = File.extname(filename)
        return ext if ext.present?
      end

      # Determine from content type
      case content_type
      when /ogg|opus/
        ".ogg"
      when /mpeg|mp3/
        ".mp3"
      when /mp4|m4a/
        ".m4a"
      when /wav/
        ".wav"
      when /webm/
        ".webm"
      else
        ".ogg" # Default for WhatsApp voice messages
      end
    end
  end
end
