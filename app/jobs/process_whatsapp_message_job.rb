# frozen_string_literal: true

# Background job for processing incoming WhatsApp messages
# Integrates with LLM conversation engine and audio transcription
#
# Workflow:
# 1. Find the WhatsappMessage record
# 2. If audio message, transcribe via Whisper
# 3. Process through LLM conversation engine
# 4. Send response back via WhatsApp
# 5. Log the conversation
#
# Usage:
#   ProcessWhatsappMessageJob.perform_later(message_id)
#
class ProcessWhatsappMessageJob < ApplicationJob
  queue_as :default

  # Retry configuration
  retry_on StandardError, wait: :polynomially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  # Don't retry on these errors
  discard_on OpenaiClient::ConfigurationError
  discard_on UnipileClient::ConfigurationError

  def perform(message_id)
    @message = WhatsappMessage.find(message_id)
    @user = @message.user

    Rails.logger.info "[ProcessWhatsappMessageJob] Processing message #{message_id} for user #{@user.id}"

    # Skip if already processed (idempotency)
    if @message.processed?
      Rails.logger.info "[ProcessWhatsappMessageJob] Message #{message_id} already processed, skipping"
      return
    end

    begin
      process_message
      @message.mark_as_processed!
      
      Rails.logger.info "[ProcessWhatsappMessageJob] Successfully processed message #{message_id}"
    rescue StandardError => e
      handle_error(e)
      raise # Re-raise for retry mechanism
    end
  end

  private

  def process_message
    case @message.message_type
    when 'audio'
      process_audio_message
    when 'text'
      process_text_message
    when 'image', 'document', 'video'
      process_media_message
    else
      Rails.logger.warn "[ProcessWhatsappMessageJob] Unknown message type: #{@message.message_type}"
      process_text_message # Fallback to text processing
    end
  end

  # ==========================================
  # Message Type Processors
  # ==========================================

  def process_audio_message
    Rails.logger.info "[ProcessWhatsappMessageJob] Processing audio message"

    # Transcribe the audio
    transcriber = WhatsappBot::AudioTranscriber.new
    
    begin
      result = transcriber.transcribe(@message)
      
      # Update message with transcription
      @message.update!(
        audio_transcription: result[:transcription],
        detected_language: result[:language],
        error_message: nil
      )
      
      Rails.logger.info "[ProcessWhatsappMessageJob] Transcription: #{result[:transcription].truncate(100)}"
      Rails.logger.info "[ProcessWhatsappMessageJob] Detected language: #{result[:language]}"
      
      # Process the transcribed text through LLM
      engine = WhatsappBot::ConversationEngine.new(
        user: @user,
        unipile_client: UnipileClient.new
      )
      
      response_text = engine.process_message(
        result[:transcription],
        detected_language: result[:language]
      )
      
      # Send response via WhatsApp
      send_whatsapp_response(response_text)
      
      log_message_processed(transcription: result[:transcription])
      
    rescue WhatsappBot::AudioTranscriber::TranscriptionError => e
      Rails.logger.error "[ProcessWhatsappMessageJob] Transcription failed: #{e.message}"
      
      # Send error message to user
      error_message = build_transcription_error_message
      send_whatsapp_response(error_message)
      
      @message.update(error_message: "Transcription failed: #{e.message}")
    end
  end

  def process_text_message
    Rails.logger.info "[ProcessWhatsappMessageJob] Processing text message"

    content = @message.content
    
    if content.blank?
      Rails.logger.warn "[ProcessWhatsappMessageJob] Empty text message, skipping"
      return
    end

    Rails.logger.info "[ProcessWhatsappMessageJob] Message content: #{content.truncate(100)}"

    # Process through LLM conversation engine
    engine = WhatsappBot::ConversationEngine.new(
      user: @user,
      unipile_client: UnipileClient.new
    )

    response_text = engine.process_message(content)

    # Send response via WhatsApp
    send_whatsapp_response(response_text)

    log_message_processed
  end

  def process_media_message
    Rails.logger.info "[ProcessWhatsappMessageJob] Processing media message: #{@message.message_type}"

    # Update content if empty
    if @message.content.blank?
      @message.update(content: "[#{@message.message_type.capitalize} reçu]")
    end

    # Send acknowledgment
    ack_message = build_media_acknowledgment
    send_whatsapp_response(ack_message)

    log_message_processed
  end

  # ==========================================
  # WhatsApp Communication
  # ==========================================

  def send_whatsapp_response(text)
    return if text.blank?

    client = UnipileClient.new
    chat_id = @user.unipile_chat_id || @message.unipile_chat_id

    if chat_id.blank?
      Rails.logger.error "[ProcessWhatsappMessageJob] No chat_id available for response"
      return
    end

    begin
      result = client.send_message(chat_id: chat_id, text: text)

      # Create outbound message record
      WhatsappMessage.create!(
        user: @user,
        unipile_message_id: result["message_id"] || "out_#{SecureRandom.uuid}",
        unipile_chat_id: chat_id,
        direction: "outbound",
        message_type: "text",
        content: text,
        processed: true,
        sent_at: Time.current
      )

      Rails.logger.info "[ProcessWhatsappMessageJob] Response sent: #{text.truncate(100)}"
    rescue UnipileClient::Error => e
      Rails.logger.error "[ProcessWhatsappMessageJob] Failed to send response: #{e.message}"
      raise # Will be retried
    end
  end

  # ==========================================
  # Helper Methods
  # ==========================================

  def log_message_processed(extra_metadata = {})
    SystemLog.log_info(
      'whatsapp_message_processed',
      description: "Processed #{@message.message_type} message",
      user: @user,
      metadata: {
        message_id: @message.id,
        unipile_message_id: @message.unipile_message_id,
        message_type: @message.message_type,
        content_preview: @message.content&.truncate(50)
      }.merge(extra_metadata)
    )
  end

  def handle_error(error)
    Rails.logger.error "[ProcessWhatsappMessageJob] Error processing message #{@message.id}: #{error.message}"
    Rails.logger.error error.backtrace.first(10).join("\n")

    # Mark the message with the error but don't mark as processed
    # so it can be retried
    @message.update(error_message: "#{error.class}: #{error.message}")

    SystemLog.log_error(
      'whatsapp_message_processing_failed',
      description: "Failed to process message: #{error.message}",
      user: @user,
      metadata: {
        message_id: @message.id,
        error_class: error.class.name,
        error_message: error.message
      }
    )
  end

  def build_transcription_error_message
    if @user.turkish?
      "Üzgünüm, sesli mesajınızı anlayamadım. Lütfen tekrar deneyin veya yazılı mesaj gönderin."
    else
      "Désolé, je n'ai pas pu comprendre votre message vocal. Veuillez réessayer ou envoyer un message texte."
    end
  end

  def build_media_acknowledgment
    type_name = case @message.message_type
                when 'image' then @user.turkish? ? "görsel" : "image"
                when 'document' then @user.turkish? ? "belge" : "document"
                when 'video' then @user.turkish? ? "video" : "vidéo"
                else @user.turkish? ? "dosya" : "fichier"
                end

    if @user.turkish?
      "#{type_name.capitalize} aldım. Şu anda yalnızca metin ve sesli mesajları işleyebiliyorum. " \
      "Bir teklif veya fatura oluşturmak için lütfen bana yazın veya sesli mesaj gönderin."
    else
      "J'ai bien reçu votre #{type_name}. Pour le moment, je ne peux traiter que les messages texte et vocaux. " \
      "Pour créer un devis ou une facture, envoyez-moi un message texte ou vocal."
    end
  end

  # ==========================================
  # Context Building (for reference)
  # ==========================================

  # Get recent messages for LLM context
  def build_conversation_context
    context_limit = AppSetting.conversation_context_messages rescue 15
    context_hours = AppSetting.conversation_context_hours rescue 2

    WhatsappMessage.context_for_user(@user, limit: context_limit, hours: context_hours)
  end

  # Check if user can create documents (for tool authorization)
  def user_can_create_documents?
    @user.can_create_documents?
  end
end
