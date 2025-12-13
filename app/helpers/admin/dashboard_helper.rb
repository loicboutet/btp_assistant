# frozen_string_literal: true

module Admin
  module DashboardHelper
    # Format a number as percentage, gracefully handling nil.
    def format_percent(value, precision: 1)
      return '—' if value.nil?
      number_to_percentage(value, precision: precision)
    end

    # Format currency in EUR, gracefully handling nil.
    def format_eur(amount)
      number_to_currency(amount.to_d, unit: '€', format: '%n %u')
    rescue StandardError
      '0 €'
    end

    # Human-friendly time (e.g. "il y a 2 heures")
    def time_ago_or_date(time)
      return '' if time.blank?
      time_ago_in_words(time)
    rescue StandardError
      I18n.l(time)
    end

    # Map SystemLog to an icon (keeps existing look and feel).
    def activity_icon_for(log)
      case log.event
      when 'stripe_invoice_paid', 'stripe_checkout_completed'
        '💳'
      when 'stripe_payment_failed', 'stripe_webhook_error', 'whatsapp_message_processing_failed'
        '❌'
      when 'whatsapp_message_received', 'whatsapp_message_processed'
        '💬'
      when 'admin_user_created', 'admin_user_updated', 'user_created', 'user_updated'
        '👤'
      when 'quote_created'
        '📋'
      when 'invoice_created'
        '📄'
      else
        '•'
      end
    end

    def activity_color_class_for(log)
      return 'bg-red' if log.log_type == 'error'
      return 'bg-orange' if log.log_type == 'warning'
      return 'bg-purple' if log.log_type == 'audit'

      # info
      'bg-green'
    end

    def activity_title_for(log)
      log.description.presence || log.event.humanize
    end

    def activity_meta_for(log)
      actor = log.actor_name
      "#{actor} - Il y a #{time_ago_in_words(log.created_at)}"
    rescue StandardError
      log.actor_name
    end
  end
end
