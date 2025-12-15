# frozen_string_literal: true

# Tool: Send Stripe payment link for subscription
# Used for new users or users who need to reactivate
#
module LlmTools
  class SendPaymentLink < BaseTool
    def execute
      # Check if user already has active subscription
      if user.active?
        return success(
          already_active: true,
          message: user.french? ?
            "Vous avez déjà un abonnement actif." :
            "Zaten aktif bir aboneliğiniz var."
        )
      end

      begin
        # Generate Stripe checkout URL
        checkout_session = create_checkout_session
        payment_url = checkout_session.url

        # Send payment link via WhatsApp
        message = build_payment_message(payment_url)
        send_whatsapp_message(message)

        log_execution("payment_link_sent", checkout_session_id: checkout_session.id)

        success(
          checkout_session_id: checkout_session.id,
          payment_url: payment_url,
          message: user.french? ?
            "Lien de paiement envoyé" :
            "Ödeme bağlantısı gönderildi"
        )
      rescue StripeService::ConfigurationError => e
        Rails.logger.error "SendPaymentLink configuration error: #{e.message}"
        error(user.french? ?
          "Le système de paiement n'est pas configuré. Veuillez contacter le support." :
          "Ödeme sistemi yapılandırılmamış. Lütfen destekle iletişime geçin.")
      rescue StripeService::ApiError => e
        Rails.logger.error "SendPaymentLink API error: #{e.message}"
        error(user.french? ?
          "Impossible de générer le lien de paiement: #{e.message}" :
          "Ödeme bağlantısı oluşturulamadı: #{e.message}")
      rescue StandardError => e
        Rails.logger.error "SendPaymentLink error: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
        error(user.french? ?
          "Une erreur est survenue lors de la génération du lien de paiement" :
          "Ödeme bağlantısı oluşturulurken bir hata oluştu")
      end
    end

    private

    def create_checkout_session
      stripe_service.create_checkout_session(
        user: user,
        success_url: success_url,
        cancel_url: cancel_url
      )
    end

    def success_url
      # URL to redirect after successful payment
      # {CHECKOUT_SESSION_ID} is replaced by Stripe with the actual session ID
      "#{base_url}/payment/success?session_id={CHECKOUT_SESSION_ID}"
    end

    def cancel_url
      "#{base_url}/payment/canceled"
    end

        def base_url
      # Get base URL from Rails configuration or environment.
      # In development, we want http://localhost:3000 by default.
      if (opts = Rails.application.config.action_mailer.default_url_options).present?
        host = opts[:host]
        port = opts[:port]
        protocol = opts[:protocol] || (Rails.env.development? ? 'http' : 'https')

        url = "#{protocol}://#{host}"
        url += ":#{port}" if port.present? && ![80, 443].include?(port.to_i)
        url
      elsif ENV['APP_HOST'].present?
        # If APP_HOST includes scheme, keep it; otherwise default to https
        host = ENV['APP_HOST'].to_s
        host.match?(/\Ahttps?:\/\//) ? host : "https://#{host}"
      else
        # Fallback
        Rails.env.development? ? 'http://localhost:3000' : 'https://app.example.com'
      end
    end

    def build_payment_message
(payment_url)
      if user.french?
        <<~MSG.strip
          💳 Lien de paiement pour votre abonnement BTP Assistant

          Cliquez sur le lien ci-dessous pour activer votre compte :
          #{payment_url}

          Abonnement mensuel : 29,90 € / mois

          Après paiement, vous pourrez créer des devis et factures illimités.
        MSG
      else
        <<~MSG.strip
          💳 BTP Assistant abonelik ödeme bağlantısı

          Hesabınızı etkinleştirmek için aşağıdaki bağlantıya tıklayın:
          #{payment_url}

          Aylık abonelik: 29,90 € / ay

          Ödeme sonrasında sınırsız teklif ve fatura oluşturabilirsiniz.
        MSG
      end
    end

    def stripe_service
      @stripe_service ||= StripeService.new
    end
  end
end
