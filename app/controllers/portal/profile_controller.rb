# frozen_string_literal: true

module Portal
  class ProfileController < Portal::BaseController
    def show
      @subscription = current_user.subscriptions.active.first ||
                      current_user.subscriptions.order(created_at: :desc).first
      @subscription_invoices = current_user.subscription_invoices
                                           .order(created_at: :desc)
                                           .limit(10)
    end

    def update
      if current_user.update(profile_params)
        log_user_action('profile_updated', "User updated their profile")
        redirect_to client_profile_path, notice: t('client.profile.updated')
      else
        @subscription = current_user.subscriptions.active.first
        @subscription_invoices = current_user.subscription_invoices
                                             .order(created_at: :desc)
                                             .limit(10)
        render :show, status: :unprocessable_entity
      end
    end

    def billing_portal
      service = StripeService.new
      session = service.create_portal_session(
        user: current_user,
        return_url: client_profile_url
      )

      log_user_action('billing_portal_accessed', "User accessed Stripe billing portal")
      redirect_to session.url, allow_other_host: true
    rescue StripeService::Error => e
      Rails.logger.error("Stripe billing portal error: #{e.message}")
      redirect_to client_profile_path, alert: t('client.profile.billing_error')
    end

    private

    def profile_params
      params.require(:user).permit(:company_name, :siret, :address, :vat_number, :preferred_language)
    end
  end
end
