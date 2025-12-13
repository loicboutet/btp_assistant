# frozen_string_literal: true

module Admin
  class SettingsController < Admin::BaseController
    before_action :load_app_setting

    def index
      # General settings overview
    end

    def update
      if @app_setting.update(general_params)
        log_admin_action('settings_updated', 'General settings were updated')
        redirect_to admin_settings_path, notice: 'Paramètres mis à jour.'
      else
        flash.now[:alert] = @app_setting.errors.full_messages.to_sentence
        render :index, status: :unprocessable_entity
      end
    end

    def unipile
      # Unipile configuration page
    end

    def update_unipile
      if @app_setting.update(unipile_params)
        log_admin_action('unipile_settings_updated', 'Unipile settings were updated')
        redirect_to admin_settings_unipile_path, notice: 'Configuration Unipile mise à jour.'
      else
        flash.now[:alert] = @app_setting.errors.full_messages.to_sentence
        render :unipile, status: :unprocessable_entity
      end
    end

    def stripe_config
      # Stripe configuration page
    end

    def update_stripe
      if @app_setting.update(stripe_params)
        log_admin_action('stripe_settings_updated', 'Stripe settings were updated')
        redirect_to admin_settings_stripe_path, notice: 'Configuration Stripe mise à jour.'
      else
        flash.now[:alert] = @app_setting.errors.full_messages.to_sentence
        render :stripe_config, status: :unprocessable_entity
      end
    end

    def openai_config
      # OpenAI configuration page
    end

    def update_openai
      if @app_setting.update(openai_params)
        log_admin_action('openai_settings_updated', 'OpenAI settings were updated')
        redirect_to admin_settings_openai_path, notice: 'Configuration OpenAI mise à jour.'
      else
        flash.now[:alert] = @app_setting.errors.full_messages.to_sentence
        render :openai_config, status: :unprocessable_entity
      end
    end

    # POST /admin/settings/test_connection
    # params[:service] in: unipile|stripe|openai
    def test_connection
      service = params[:service].to_s

      result = case service
               when 'unipile'
                 test_unipile
               when 'stripe'
                 test_stripe
               when 'openai'
                 test_openai
               else
                 { ok: false, message: 'Service invalide' }
               end

      log_admin_action(
        'settings_test_connection',
        "Test connexion #{service}: #{result[:ok] ? 'OK' : 'KO'}",
        service: service,
        ok: result[:ok],
        message: result[:message]
      )

      respond_to do |format|
        format.json { render json: { success: result[:ok], message: result[:message], service: service } }
        format.html do
          redirect_back fallback_location: admin_settings_path,
                        notice: (result[:ok] ? result[:message] : nil),
                        alert: (result[:ok] ? nil : result[:message])
        end
      end
    end

    private

    def load_app_setting
      @app_setting = AppSetting.instance
    end

    def general_params
      params.fetch(:app_setting, {}).permit(
        :signed_url_expiration_minutes,
        :conversation_context_messages,
        :conversation_context_hours,
        :rate_limit_messages_per_hour
      )
    end

    def unipile_params
      params.require(:app_setting).permit(:unipile_dsn, :unipile_account_id, :unipile_api_key)
    end

    def stripe_params
      params.require(:app_setting).permit(:stripe_publishable_key, :stripe_secret_key, :stripe_price_id, :stripe_webhook_secret)
    end

    def openai_params
      params.require(:app_setting).permit(:openai_api_key, :openai_model)
    end

    def test_unipile
      client = UnipileClient.new
      info = client.get_account_info
      phone = info.dig('connection', 'phone_number') || info.dig('phone_number')
      suffix = phone.present? ? " (numéro: #{phone})" : ''
      { ok: true, message: "Unipile OK#{suffix}" }
    rescue UnipileClient::ConfigurationError => e
      { ok: false, message: "Unipile non configuré : #{e.message}" }
    rescue UnipileClient::AuthenticationError => e
      { ok: false, message: "Unipile auth KO : #{e.message}" }
    rescue UnipileClient::ApiError => e
      { ok: false, message: "Unipile API KO : #{e.message}" }
    rescue StandardError => e
      { ok: false, message: "Unipile KO : #{e.message}" }
    end

    def test_stripe
      StripeService.new # validates key
      Stripe::Balance.retrieve
      { ok: true, message: 'Stripe OK (API accessible)' }
    rescue StripeService::ConfigurationError => e
      { ok: false, message: "Stripe non configuré : #{e.message}" }
    rescue Stripe::StripeError => e
      { ok: false, message: "Stripe API KO : #{e.message}" }
    rescue StandardError => e
      { ok: false, message: "Stripe KO : #{e.message}" }
    end

    def test_openai
      client = OpenaiClient.new
      resp = client.chat(messages: [{ role: 'user', content: 'ping' }], temperature: 0)
      content = resp[:content].to_s.strip
      suffix = content.present? ? " (réponse: #{content.tr("\n", ' ')[0, 80]})" : ''
      { ok: true, message: "OpenAI OK#{suffix}" }
    rescue OpenaiClient::ConfigurationError => e
      { ok: false, message: "OpenAI non configuré : #{e.message}" }
    rescue OpenaiClient::ApiError => e
      { ok: false, message: "OpenAI API KO : #{e.message}" }
    rescue StandardError => e
      { ok: false, message: "OpenAI KO : #{e.message}" }
    end
  end
end
