# frozen_string_literal: true

module Webhooks
  module Unipile
    # Handles incoming WhatsApp messages from Unipile webhook
    # POST /webhooks/unipile/messages
    #
    # Webhook payload structure (from Unipile docs):
    # {
    #   "event": "message_received",
    #   "account_id": "acc_456",
    #   "chat_id": "chat_789",
    #   "message_id": "msg_123",
    #   "message": "Message content",
    #   "sender": {
    #     "attendee_id": "att_012",
    #     "attendee_name": "Jean",
    #     "attendee_provider_id": "+33612345678"
    #   },
    #   "attendees": [...],
    #   "attachments": { "type": "audio", ... },
    #   "timestamp": "2023-09-24T13:49:07.965Z"
    # }
    #
    class MessagesController < ApplicationController
      # Skip CSRF for webhook
      skip_before_action :verify_authenticity_token

      def create
        # Log raw webhook for debugging
        Rails.logger.info "[Unipile Webhook] Received: #{webhook_params.to_json}"

        # 1. Verify account_id matches our configured account
        unless valid_account_id?
          Rails.logger.warn "[Unipile Webhook] Invalid account_id: #{webhook_account_id}"
          # En dev/staging on ignore simplement (200) pour éviter les retries Unipile
          # quand plusieurs comptes envoient sur le même webhook.
          return head(Rails.env.production? ? :unauthorized : :ok)
        end

        # 2. Check for supported event types
        unless supported_event?
          Rails.logger.info "[Unipile Webhook] Ignoring unsupported event: #{event_type}"
          return head :ok
        end

        # 2b. Ignore messages sent by our own WhatsApp account (avoid bot replying to itself)
        if sender_is_bot?
          Rails.logger.info "[Unipile Webhook] Ignoring self-sent message: #{unipile_message_id}"
          return head :ok
        end

        # 3. Check for duplicate message (idempotency)
        if WhatsappMessage.duplicate?(unipile_message_id)
          Rails.logger.info "[Unipile Webhook] Duplicate message ignored: #{unipile_message_id}"
          return head :ok
        end

        # 4. Extract phone number and find or create user
        phone_number = extract_phone_number
        if phone_number.blank?
          Rails.logger.error "[Unipile Webhook] Could not extract phone number from payload"
          return head :unprocessable_entity
        end

        user = find_or_create_user(phone_number)
        unless user
          Rails.logger.error "[Unipile Webhook] Could not find or create user for: #{phone_number}"
          return head :unprocessable_entity
        end

        # 5. Create WhatsappMessage record
        message = create_whatsapp_message(user)
        unless message.persisted?
          Rails.logger.error "[Unipile Webhook] Failed to create message: #{message.errors.full_messages}"
          return head :unprocessable_entity
        end

        # 6. Update user's Unipile IDs if needed
        update_user_unipile_info(user)

        # 7. Queue background job for processing
        ProcessWhatsappMessageJob.perform_later(message.id)

        # 8. Log the event
        SystemLog.log_info(
          'whatsapp_message_received',
          description: "#{message_type} message from #{user.display_name}",
          user: user,
          metadata: {
            message_id: message.id,
            unipile_message_id: unipile_message_id,
            message_type: message_type
          }
        )

        head :ok
      rescue StandardError => e
        Rails.logger.error "[Unipile Webhook] Error: #{e.message}"
        Rails.logger.error e.backtrace.first(5).join("\n")
        head :internal_server_error
      end

      private

      # ==========================================
      # Payload Accessors
      # ==========================================

      def webhook_params
        @webhook_params ||= params.permit!.to_h
      end

      def webhook_account_id
        webhook_params['account_id']
      end

      def event_type
        webhook_params['event']
      end

      def unipile_message_id
        webhook_params['message_id'] || webhook_params.dig('data', 'id')
      end

      def chat_id
        webhook_params['chat_id'] || webhook_params.dig('data', 'chat_id')
      end

      def message_content
        webhook_params['message'] || webhook_params.dig('data', 'text') || ''
      end

      def message_timestamp
        timestamp = webhook_params['timestamp'] || webhook_params.dig('data', 'timestamp')
        Time.parse(timestamp) rescue Time.current
      end

      def sender_info
        webhook_params['sender'] || webhook_params.dig('data', 'sender') || {}
      end

      def attendee_info
        # Attendee might be in different places depending on payload structure
        webhook_params.dig('data', 'attendee') || sender_info
      end

      def attachments_info
        webhook_params['attachments'] || webhook_params.dig('data', 'attachments')
      end

      # ==========================================
      # Validation Helpers
      # ==========================================

      def valid_account_id?
        configured_account_id = AppSetting.unipile_account_id
        return true if configured_account_id.blank? # Skip validation if not configured

        webhook_account_id == configured_account_id
      end

      def supported_event?
        # Only process message_received events
        # Ignore reactions, read receipts, edited/deleted messages
        event_type.in?(['message_received', nil]) # nil for backwards compatibility
      end


      def sender_is_bot?
        bot_phone = normalize_phone(AppSetting.instance.whatsapp_business_number)

        # Best-effort auto-fill in non-prod if missing
        if bot_phone.blank? && !Rails.env.production?
          begin
            info = UnipileClient.new.get_account_info
            raw = info.dig('connection_params', 'im', 'phone_number') || info['name']
            bot_phone = normalize_phone(raw)
            AppSetting.instance.update_column(:whatsapp_business_number, bot_phone) if bot_phone.present?
          rescue StandardError
            # ignore
          end
        end

        sender_phone = normalize_phone(sender_info['attendee_provider_id'] || attendee_info['attendee_provider_id'])
        return false if bot_phone.blank? || sender_phone.blank?

        sender_phone == bot_phone
      end

      def normalize_phone(value)
        return nil if value.blank?

        v = value.to_s
        v = v.split('@').first if v.include?('@')
        v = "+#{v}" unless v.start_with?('+')
        v
      end
      # ==========================================
      # Data Extraction
      # ==========================================

      def extract_phone_number
        # Try multiple paths for phone number
        phone = attendee_info['identifier'] ||
                attendee_info['attendee_provider_id'] ||
                sender_info['attendee_provider_id'] ||
                extract_phone_from_attendee_id

        return nil if phone.blank?

        # Clean up WhatsApp format: 33612345678@s.whatsapp.net -> +33612345678
        phone = phone.split('@').first if phone.include?('@')
        phone = "+#{phone}" unless phone.start_with?('+')
        
        phone
      end

      def extract_phone_from_attendee_id
        attendee_id = attendee_info['attendee_id'] || sender_info['attendee_id']
        return nil if attendee_id.blank?

        # Some attendee IDs contain the phone number
        match = attendee_id.match(/(\d{10,15})/)
        match ? match[1] : nil
      end

def message_type
  # Determine message type from attachments
  attachments = attachments_info

  if attachments.present?
    attachment = attachments.is_a?(Array) ? attachments.first : attachments
    attachment_type = attachment.is_a?(Hash) ? (attachment['type'] || attachment['attachment_type']) : nil

    case attachment_type
    when 'audio', 'voice', 'voice_note', 'opus'
      'audio'
    when 'image', 'img'
      'image'
    when 'video'
      'video'
    when 'document', 'file'
      'document'
    else
      # Some payloads (voice notes) have voice_note: true
      attachment.is_a?(Hash) && attachment['voice_note'] ? 'audio' : 'text'
    end
  else
    'text'
  end
end

def attachment_id
  attachments = attachments_info
  return nil unless attachments.present?

  attachment = attachments.is_a?(Array) ? attachments.first : attachments
  return nil unless attachment.is_a?(Hash)

  attachment['id'] || attachment['attachment_id']
end

# ==========================================
# User Management

      # ==========================================

      def find_or_create_user(phone_number)
        user = User.find_by(phone_number: phone_number)

        if user.nil?
          user = User.new(
            phone_number: phone_number,
            subscription_status: 'pending',
            preferred_language: detect_language
          )

          if user.save
            user.record_first_message!
            Rails.logger.info "[Unipile Webhook] Created new user: #{phone_number}"
          else
            Rails.logger.error "[Unipile Webhook] Failed to create user: #{user.errors.full_messages}"
            return nil
          end
        end

        user.record_activity!
        user
      end

      def update_user_unipile_info(user)
        updates = {}
        updates[:unipile_chat_id] = chat_id if chat_id.present? && user.unipile_chat_id != chat_id
        
        attendee_id = attendee_info['attendee_id'] || sender_info['attendee_id']
        updates[:unipile_attendee_id] = attendee_id if attendee_id.present? && user.unipile_attendee_id != attendee_id

        user.update_columns(updates) if updates.any?
      end

      def detect_language
        # Default to French, can be enhanced with language detection later
        'fr'
      end

      # ==========================================
      # Message Creation
      # ==========================================

      def create_whatsapp_message(user)
        WhatsappMessage.create(
          user: user,
          unipile_message_id: unipile_message_id,
          unipile_chat_id: chat_id,
          direction: 'inbound',
          message_type: message_type,
          content: message_content,
          raw_payload: webhook_params,
          sent_at: message_timestamp,
          processed: false
        )
      end
    end
  end
end
