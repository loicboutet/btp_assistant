# frozen_string_literal: true

# StripeService handles all Stripe API interactions
# Including customer management, checkout sessions, and subscriptions
#
# Usage:
#   service = StripeService.new
#   service.create_customer(user)
#   service.create_checkout_session(user: user, success_url: "...", cancel_url: "...")
#
class StripeService
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class ApiError < Error; end

  def initialize
    @api_key = settings.stripe_secret_key
    validate_configuration!
    Stripe.api_key = @api_key
  end

  # Create a Stripe customer for a user
  # @param user [User] The user to create a customer for
  # @return [Stripe::Customer] The created customer
  def create_customer(user)
    Stripe::Customer.create(
      phone: user.phone_number,
      name: user.company_name,
      metadata: {
        user_id: user.id,
        siret: user.siret
      }
    )
  rescue Stripe::StripeError => e
    raise ApiError, "Failed to create customer: #{e.message}"
  end

  # Get or create a Stripe customer for a user
  # @param user [User] The user
  # @return [String] The Stripe customer ID
  def ensure_customer(user)
    return user.stripe_customer_id if user.stripe_customer_id.present?

    customer = create_customer(user)
    user.update!(stripe_customer_id: customer.id)
    customer.id
  rescue Stripe::StripeError => e
    raise ApiError, "Failed to ensure customer: #{e.message}"
  end

  # Create a checkout session for subscription
  # @param user [User] The user subscribing
  # @param success_url [String] URL to redirect on success
  # @param cancel_url [String] URL to redirect on cancel
  # @return [Stripe::Checkout::Session]
  def create_checkout_session(user:, success_url:, cancel_url:)
    customer_id = ensure_customer(user)

    Stripe::Checkout::Session.create(
      customer: customer_id,
      mode: 'subscription',
      line_items: [{
        price: settings.stripe_price_id,
        quantity: 1
      }],
      success_url: success_url,
      cancel_url: cancel_url,
      metadata: {
        user_id: user.id.to_s
      },
      subscription_data: {
        metadata: {
          user_id: user.id.to_s
        }
      }
    )
  rescue Stripe::StripeError => e
    raise ApiError, "Failed to create checkout session: #{e.message}"
  end

  # Create a billing portal session for subscription management
  # @param user [User] The user
  # @param return_url [String] URL to return to after portal
  # @return [Stripe::BillingPortal::Session]
  def create_portal_session(user:, return_url:)
    raise Error, "User has no Stripe customer" unless user.stripe_customer_id.present?

    Stripe::BillingPortal::Session.create(
      customer: user.stripe_customer_id,
      return_url: return_url
    )
  rescue Stripe::StripeError => e
    raise ApiError, "Failed to create portal session: #{e.message}"
  end

  # Retrieve a subscription
  # @param subscription_id [String] Stripe subscription ID
  # @return [Stripe::Subscription]
  def get_subscription(subscription_id)
    Stripe::Subscription.retrieve(subscription_id)
  rescue Stripe::StripeError => e
    raise ApiError, "Failed to retrieve subscription: #{e.message}"
  end

  # Cancel a subscription at period end
  # @param subscription_id [String] Stripe subscription ID
  # @return [Stripe::Subscription]
  def cancel_subscription(subscription_id)
    Stripe::Subscription.update(
      subscription_id,
      cancel_at_period_end: true
    )
  rescue Stripe::StripeError => e
    raise ApiError, "Failed to cancel subscription: #{e.message}"
  end

  # Reactivate a subscription that was set to cancel at period end
  # @param subscription_id [String] Stripe subscription ID
  # @return [Stripe::Subscription]
  def reactivate_subscription(subscription_id)
    Stripe::Subscription.update(
      subscription_id,
      cancel_at_period_end: false
    )
  rescue Stripe::StripeError => e
    raise ApiError, "Failed to reactivate subscription: #{e.message}"
  end

  # Verify webhook signature
  # @param payload [String] Raw request body
  # @param signature [String] Stripe-Signature header
  # @return [Stripe::Event]
  def verify_webhook(payload:, signature:)
    Stripe::Webhook.construct_event(
      payload,
      signature,
      settings.stripe_webhook_secret
    )
  rescue JSON::ParserError => e
    raise Error, "Invalid payload: #{e.message}"
  rescue Stripe::SignatureVerificationError => e
    raise e # Re-raise for controller to handle
  end

  private

  def settings
    @settings ||= AppSetting.instance
  end

  def validate_configuration!
    raise ConfigurationError, "Stripe API key not configured" if @api_key.blank?
  end
end
