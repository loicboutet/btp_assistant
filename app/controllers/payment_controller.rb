# frozen_string_literal: true

# Handles payment result pages after Stripe checkout.
#
# NOTE: Webhooks are the source of truth.
# However, in local/dev environments (or if a webhook is missed), we can
# reconcile the payment status by querying Stripe using the session_id.
#
class PaymentController < ApplicationController
  def success
    @session_id = params[:session_id].to_s.presence

    SystemLog.log_info(
      'payment_success_page_viewed',
      description: 'Payment success page viewed',
      metadata: { session_id: @session_id }
    )

    return if @session_id.blank?

    # Best-effort reconciliation (no webhook required)
    reconcile_checkout_session(@session_id)
  end

  def canceled
    SystemLog.log_info(
      'payment_canceled_page_viewed',
      description: 'Payment canceled page viewed'
    )
  end

  private

  def reconcile_checkout_session(session_id)
    StripeService.new # sets Stripe.api_key

    session = Stripe::Checkout::Session.retrieve(
      {
        id: session_id,
        expand: ['customer', 'subscription', 'subscription.items', 'subscription.items.data.price']
      }
    )

    paid = (session.payment_status.to_s == 'paid') || (session.status.to_s == 'complete')
    return unless paid

    user = find_user_from_checkout_session(session)
    return unless user

    customer_id = session.customer.respond_to?(:id) ? session.customer.id : session.customer

    ActiveRecord::Base.transaction do
      # Ensure customer id is stored
      user.update!(
        stripe_customer_id: user.stripe_customer_id.presence || customer_id,
        subscription_status: 'active'
      )

      # Create/update local Subscription record if Stripe provided one
      if session.subscription.respond_to?(:id)
        stripe_sub = session.subscription

        price_id = stripe_sub.items&.data&.first&.price&.id

        record = user.subscriptions.find_or_initialize_by(stripe_subscription_id: stripe_sub.id)
        record.update!(
          stripe_price_id: price_id,
          status: stripe_sub.status,
          current_period_start: (stripe_sub.respond_to?(:current_period_start) && stripe_sub.current_period_start ? Time.at(stripe_sub.current_period_start) : nil),
          current_period_end: (stripe_sub.respond_to?(:current_period_end) && stripe_sub.current_period_end ? Time.at(stripe_sub.current_period_end) : nil),
          cancel_at_period_end: stripe_sub.cancel_at_period_end || false
        )
      end
    end

    SystemLog.log_info(
      'payment_reconciled_without_webhook',
      description: 'Payment reconciled from checkout session (no webhook)',
      user: user,
      metadata: {
        session_id: session_id,
        customer_id: customer_id,
        subscription_id: (session.subscription.respond_to?(:id) ? session.subscription.id : session.subscription)
      }
    )
  rescue Stripe::StripeError => e
    Rails.logger.warn "[PaymentController] Stripe reconciliation failed: #{e.class}: #{e.message}"
  rescue StandardError => e
    Rails.logger.error "[PaymentController] Reconciliation error: #{e.class}: #{e.message}"
  end

  def find_user_from_checkout_session(session)
    meta = session.metadata.respond_to?(:to_h) ? session.metadata.to_h : {}
    user_id = meta['user_id'].presence

    user = User.find_by(id: user_id) if user_id
    return user if user

    customer_id = session.customer.respond_to?(:id) ? session.customer.id : session.customer
    return nil if customer_id.blank?

    User.find_by(stripe_customer_id: customer_id)
  end
end
