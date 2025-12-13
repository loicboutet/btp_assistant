# frozen_string_literal: true

module Admin
  class WebhooksController < Admin::BaseController
    helper_method :replay_allowed?

    # Webhooks monitoring is currently implemented as a view over SystemLog + related records.
    # (There is no dedicated WebhookEvent model yet.)

    def index
      @filters = {
        source: params[:source].to_s.strip.presence, # 'stripe' / 'unipile'
        status: params[:status].to_s.strip.presence, # 'success' / 'error'
        user_id: params[:user_id].to_s.strip.presence,
        from: params[:from].to_s.strip.presence,
        to: params[:to].to_s.strip.presence
      }

      logs = SystemLog.where(
        event: [
          # Stripe
          'stripe_checkout_completed',
          'stripe_subscription_created',
          'stripe_subscription_updated',
          'stripe_subscription_deleted',
          'stripe_invoice_paid',
          'stripe_payment_failed',
          'stripe_webhook_error',
          'stripe_webhook_user_not_found',
          # Unipile
          'whatsapp_message_received',
          'whatsapp_message_processed',
          'whatsapp_message_processing_failed'
        ]
      )

      if @filters[:source].present?
        logs = case @filters[:source]
               when 'stripe' then logs.where("event LIKE 'stripe_%'")
               when 'unipile' then logs.where("event LIKE 'whatsapp_%'")
               else logs
               end
      end

      if @filters[:status].present?
        logs = case @filters[:status]
               when 'success' then logs.where(log_type: %w[info audit])
               when 'error' then logs.where(log_type: %w[warning error])
               else logs
               end
      end

      logs = logs.where(user_id: @filters[:user_id]) if @filters[:user_id].present?

      if @filters[:from].present?
        from_time = Time.zone.parse(@filters[:from]) rescue nil
        logs = logs.where('created_at >= ?', from_time.beginning_of_day) if from_time
      end

      if @filters[:to].present?
        to_time = Time.zone.parse(@filters[:to]) rescue nil
        logs = logs.where('created_at <= ?', to_time.end_of_day) if to_time
      end

      logs = logs.includes(:user).order(created_at: :desc)
      @webhooks = paginate(logs, per_page: 50)

      @users_for_filter = User.order(:id).limit(200)
    end

    # GET /admin/webhooks/:id/replay
    # POST /admin/webhooks/:id/replay
    def replay
      @webhook = SystemLog.includes(:user).find(params[:id])

      unless replay_allowed?(@webhook)
        return redirect_to admin_webhooks_path, alert: 'Rejeu refusé: événement non rejouable ou données insuffisantes.'
      end

      return unless request.post?

      replay_webhook!(@webhook)

      log_admin_action('webhook_replayed', "Webhook #{params[:id]} was replayed", webhook_event: @webhook.event)
      redirect_to admin_webhooks_path, notice: 'Webhook rejoué avec succès.'
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_webhooks_path, alert: 'Webhook introuvable.'
    rescue StandardError => e
      SystemLog.log_error(
        'admin_webhook_replay_failed',
        description: e.message,
        admin: current_admin,
        metadata: { webhook_id: params[:id] },
        request: request
      )
      redirect_to admin_webhooks_path, alert: "Échec du rejeu: #{e.message}"
    end

    private

    def replay_allowed?(log)
      # Only allow replay of Unipile message processing failures for now.
      # Stripe replay would require storing raw payload + signature.
      return false unless log.event == 'whatsapp_message_processing_failed'

      message_id = log.metadata.is_a?(Hash) ? (log.metadata['message_id'] || log.metadata[:message_id]) : nil
      return false if message_id.blank?

      WhatsappMessage.exists?(id: message_id)
    end

    def replay_webhook!(log)
      message_id = log.metadata['message_id'] || log.metadata[:message_id]
      message = WhatsappMessage.find(message_id)

      # Security: avoid replaying outbound messages
      raise 'Rejeu interdit pour un message sortant' if message.direction != 'inbound'

      # Mark as unprocessed to let the job run (idempotent checks in job will skip processed)
      message.update!(processed: false)
      ProcessWhatsappMessageJob.perform_later(message.id)
    end
  end
end
