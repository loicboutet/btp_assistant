# frozen_string_literal: true

module Admin
  class DashboardController < Admin::BaseController
    UNIPILE_WEBHOOK_EVENTS = %w[
      whatsapp_message_received
      whatsapp_message_processed
      whatsapp_message_processing_failed
    ].freeze

    STRIPE_WEBHOOK_EVENTS = %w[
      stripe_checkout_completed
      stripe_subscription_created
      stripe_subscription_updated
      stripe_subscription_deleted
      stripe_invoice_paid
      stripe_payment_failed
      stripe_webhook_error
      stripe_webhook_user_not_found
    ].freeze

    # Events considered "failed" webhook executions
    UNIPILE_FAILURE_EVENTS = %w[whatsapp_message_processing_failed].freeze
    STRIPE_FAILURE_EVENTS = %w[stripe_payment_failed stripe_webhook_error stripe_webhook_user_not_found].freeze

    def index
      # Users
      @total_users = User.count
      @active_users = User.active.count
      @past_due_users = User.past_due.count
      @active_users_30d = User.where('last_activity_at >= ?', 30.days.ago).count
      @new_users_7d = User.where('created_at >= ?', 7.days.ago).count

      # Subscriptions
      @active_subscriptions = Subscription.active.count
      @past_due_subscriptions = Subscription.past_due.count
      @overdue_subscriptions_list = Subscription.past_due.includes(:user).order(updated_at: :desc).limit(5)

      # Revenue (estimated MRR)
      @mrr_estimated = compute_mrr
      @arpu_estimated = @active_users.positive? ? (@mrr_estimated.to_d / @active_users).round(2) : 0.to_d

      # Documents
      @quotes_count = Quote.count
      @invoices_count = Invoice.count
      @documents_total = @quotes_count + @invoices_count
      @documents_7d = Quote.where('created_at >= ?', 7.days.ago).count + Invoice.where('created_at >= ?', 7.days.ago).count
      @quotes_this_month = Quote.where('created_at >= ?', Time.current.beginning_of_month).count
      @invoices_this_month = Invoice.where('created_at >= ?', Time.current.beginning_of_month).count

      # WhatsApp activity
      @messages_24h = WhatsappMessage.where('created_at >= ?', 24.hours.ago).count
      @messages_this_month = WhatsappMessage.where('created_at >= ?', Time.current.beginning_of_month).count

      # Webhook health (24h)
      @webhook_stats_24h = webhook_stats(from: 24.hours.ago)
      @webhook_success_rate_24h = @webhook_stats_24h[:success_rate]

      # Recent activity
      @recent_logs = SystemLog.recent.includes(:user, :admin_user).limit(10)
    end

    def metrics
      # Activity volumes
      @messages_today = WhatsappMessage.where('created_at >= ?', Time.current.beginning_of_day).count
      @quotes_today = Quote.where('created_at >= ?', Time.current.beginning_of_day).count
      @invoices_today = Invoice.where('created_at >= ?', Time.current.beginning_of_day).count
      @documents_today = @quotes_today + @invoices_today

      @messages_7d = WhatsappMessage.where('created_at >= ?', 7.days.ago).count
      @quotes_7d = Quote.where('created_at >= ?', 7.days.ago).count
      @invoices_7d = Invoice.where('created_at >= ?', 7.days.ago).count
      @documents_7d = @quotes_7d + @invoices_7d

      # Users / Subs
      @total_users = User.count
      @active_users = User.active.count
      @past_due_users = User.past_due.count
      @active_users_30d = User.where('last_activity_at >= ?', 30.days.ago).count
      @new_users_30d = User.where('created_at >= ?', 30.days.ago).count

      @users_by_status = User.group(:subscription_status).count
      @subscriptions_by_status = Subscription.group(:status).count
      @subscriptions_total = @subscriptions_by_status.values.sum

      # Revenue
      @mrr_estimated = compute_mrr
      @arr_estimated = (@mrr_estimated.to_d * 12).round(2)
      @arpu_estimated = @active_users.positive? ? (@mrr_estimated.to_d / @active_users).round(2) : 0.to_d

      # Documents (30j)
      @quotes_30d = Quote.where('created_at >= ?', 30.days.ago).count
      @invoices_30d = Invoice.where('created_at >= ?', 30.days.ago).count
      @documents_30d = @quotes_30d + @invoices_30d
      @documents_per_active_user_30d = @active_users_30d.positive? ? (@documents_30d.to_f / @active_users_30d).round(1) : 0.0

      # WhatsApp & AI
      @whatsapp_connected_users = User.where.not(unipile_chat_id: nil).count
      @whatsapp_connected_users_rate = @total_users.positive? ? ((@whatsapp_connected_users.to_f / @total_users) * 100).round(1) : 0.0

      @messages_30d = WhatsappMessage.where('created_at >= ?', 30.days.ago).count
      @voice_transcribed_30d = WhatsappMessage.where('created_at >= ?', 30.days.ago)
                                              .where(message_type: 'audio')
                                              .where.not(audio_transcription: [nil, ''])
                                              .count

      inbound_30d = WhatsappMessage.where('created_at >= ?', 30.days.ago).where(direction: 'inbound')
      inbound_processed_success_30d = inbound_30d.where(processed: true, error_message: nil).count
      inbound_total_30d = inbound_30d.count
      @ai_success_rate_30d = inbound_total_30d.positive? ? ((inbound_processed_success_30d.to_f / inbound_total_30d) * 100).round(1) : nil

      # Webhook health
      @webhook_stats_24h = webhook_stats(from: 24.hours.ago)
      @webhook_success_rate_24h = @webhook_stats_24h[:success_rate]
      @unipile_webhook_stats_24h = webhook_stats(from: 24.hours.ago, source: :unipile)
      @stripe_webhook_stats_24h = webhook_stats(from: 24.hours.ago, source: :stripe)

      # Languages
      @users_by_language = User.group(:preferred_language).count
    end

    private

    def compute_mrr
      # Prefer Stripe invoices linked to the current subscription period.
      period_mrr = SubscriptionInvoice.paid
                                      .where('period_start <= ? AND (period_end IS NULL OR period_end >= ?)', Date.current, Date.current)
                                      .sum(:amount)
      return period_mrr.to_d if period_mrr.to_d.positive?

      # Fallback: paid invoices in last ~35 days (for missing period dates)
      SubscriptionInvoice.paid.where('paid_at >= ?', 35.days.ago).sum(:amount).to_d
    rescue StandardError
      0.to_d
    end

    # Computes webhook stats based on SystemLog entries.
    # This app currently has no dedicated WebhookEvent model.
    #
    # @param from [Time]
    # @param source [:all, :unipile, :stripe]
    # @return [Hash]
    def webhook_stats(from:, source: :all)
      events, failure_events = case source
                               when :unipile
                                 [UNIPILE_WEBHOOK_EVENTS, UNIPILE_FAILURE_EVENTS]
                               when :stripe
                                 [STRIPE_WEBHOOK_EVENTS, STRIPE_FAILURE_EVENTS]
                               else
                                 [UNIPILE_WEBHOOK_EVENTS + STRIPE_WEBHOOK_EVENTS,
                                  UNIPILE_FAILURE_EVENTS + STRIPE_FAILURE_EVENTS]
                               end

      scope = SystemLog.where('created_at >= ?', from).where(event: events)
      total = scope.count
      failed = scope.where(event: failure_events).count
      success = total - failed

      {
        total: total,
        success: success,
        failed: failed,
        success_rate: total.positive? ? ((success.to_f / total) * 100).round(1) : nil
      }
    end
  end
end
