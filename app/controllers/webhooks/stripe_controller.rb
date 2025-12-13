# frozen_string_literal: true

module Webhooks
  # Handles Stripe webhook events for subscription management
  # Endpoint: POST /webhooks/stripe
  #
  # Events handled:
  # - checkout.session.completed: User completed checkout
  # - customer.subscription.created: Subscription created
  # - customer.subscription.updated: Subscription status changed
  # - customer.subscription.deleted: Subscription canceled
  # - invoice.paid: Payment successful
  # - invoice.payment_failed: Payment failed
  #
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      payload = request.body.read
      signature = request.headers['Stripe-Signature']

      begin
        event = stripe_service.verify_webhook(payload: payload, signature: signature)
      rescue Stripe::SignatureVerificationError => e
        log_webhook_error("Invalid signature", e)
        return head :bad_request
      rescue StripeService::Error => e
        log_webhook_error("Webhook verification failed", e)
        return head :bad_request
      end

      handle_event(event)
      head :ok
    rescue StandardError => e
      log_webhook_error("Webhook processing failed", e)
      head :internal_server_error
    end

    private

    def handle_event(event)
      Rails.logger.info "Processing Stripe event: #{event.type}"
      
      case event.type
      when 'checkout.session.completed'
        handle_checkout_completed(event.data.object)
      when 'customer.subscription.created'
        handle_subscription_created(event.data.object)
      when 'customer.subscription.updated'
        handle_subscription_updated(event.data.object)
      when 'customer.subscription.deleted'
        handle_subscription_deleted(event.data.object)
      when 'invoice.paid'
        handle_invoice_paid(event.data.object)
      when 'invoice.payment_failed'
        handle_invoice_payment_failed(event.data.object)
      else
        Rails.logger.info "Unhandled Stripe event: #{event.type}"
      end
    end

    def handle_checkout_completed(session)
      user = find_user_from_session(session)
      return log_missing_user("checkout.session.completed", session) unless user

      # Update user status
      user.update!(subscription_status: 'active')

      SystemLog.log_info(
        'stripe_checkout_completed',
        description: "Checkout completed for user #{user.id}",
        user: user,
        metadata: { session_id: session.id, customer_id: session.customer }
      )
    end

    def handle_subscription_created(subscription)
      user = find_user_by_customer(subscription.customer)
      return log_missing_user("customer.subscription.created", subscription) unless user

      create_or_update_subscription(user, subscription)

      SystemLog.log_info(
        'stripe_subscription_created',
        description: "Subscription created for user #{user.id}",
        user: user,
        metadata: { subscription_id: subscription.id, status: subscription.status }
      )
    end

    def handle_subscription_updated(subscription)
      user = find_user_by_customer(subscription.customer)
      return log_missing_user("customer.subscription.updated", subscription) unless user

      record = create_or_update_subscription(user, subscription)

      # Update user subscription status based on Stripe status
      new_status = map_stripe_status(subscription.status)
      user.update!(subscription_status: new_status)

      SystemLog.log_info(
        'stripe_subscription_updated',
        description: "Subscription updated for user #{user.id}: #{subscription.status}",
        user: user,
        metadata: { 
          subscription_id: subscription.id, 
          status: subscription.status,
          cancel_at_period_end: subscription.cancel_at_period_end
        }
      )
    end

    def handle_subscription_deleted(subscription)
      user = find_user_by_customer(subscription.customer)
      return log_missing_user("customer.subscription.deleted", subscription) unless user

      record = user.subscriptions.find_by(stripe_subscription_id: subscription.id)
      record&.update!(status: 'canceled', canceled_at: Time.current)

      user.update!(subscription_status: 'canceled')

      SystemLog.log_warning(
        'stripe_subscription_deleted',
        description: "Subscription canceled for user #{user.id}",
        user: user,
        metadata: { subscription_id: subscription.id }
      )
    end

    def handle_invoice_paid(invoice)
      # Skip invoices not related to subscriptions (one-time payments)
      return unless invoice.subscription.present?

      user = find_user_by_customer(invoice.customer)
      return log_missing_user("invoice.paid", invoice) unless user

      subscription = user.subscriptions.find_by(stripe_subscription_id: invoice.subscription)

      # Prevent duplicate invoice records
      return if user.subscription_invoices.exists?(stripe_invoice_id: invoice.id)

      user.subscription_invoices.create!(
        subscription: subscription,
        stripe_invoice_id: invoice.id,
        invoice_number: invoice.number,
        amount: (invoice.amount_paid || 0) / 100.0,
        currency: invoice.currency,
        status: 'paid',
        period_start: invoice.period_start ? Time.at(invoice.period_start).to_date : nil,
        period_end: invoice.period_end ? Time.at(invoice.period_end).to_date : nil,
        paid_at: Time.current,
        stripe_invoice_url: invoice.hosted_invoice_url,
        stripe_invoice_pdf: invoice.invoice_pdf
      )

      SystemLog.log_info(
        'stripe_invoice_paid',
        description: "Invoice paid for user #{user.id}: #{invoice.number}",
        user: user,
        metadata: { 
          invoice_id: invoice.id, 
          amount: (invoice.amount_paid || 0) / 100.0,
          currency: invoice.currency
        }
      )
    end

    def handle_invoice_payment_failed(invoice)
      user = find_user_by_customer(invoice.customer)
      return log_missing_user("invoice.payment_failed", invoice) unless user

      user.update!(subscription_status: 'past_due')

      SystemLog.log_warning(
        'stripe_payment_failed',
        description: "Payment failed for user #{user.id}",
        user: user,
        metadata: { 
          invoice_id: invoice.id,
          attempt_count: invoice.attempt_count
        }
      )
    end

    def create_or_update_subscription(user, stripe_sub)
      record = user.subscriptions.find_or_initialize_by(
        stripe_subscription_id: stripe_sub.id
      )

      # Extract price ID from items
      price_id = extract_price_id(stripe_sub)

      record.update!(
        stripe_price_id: price_id,
        status: stripe_sub.status,
        current_period_start: stripe_sub.current_period_start ? Time.at(stripe_sub.current_period_start) : nil,
        current_period_end: stripe_sub.current_period_end ? Time.at(stripe_sub.current_period_end) : nil,
        cancel_at_period_end: stripe_sub.cancel_at_period_end || false
      )

      record
    end

    def extract_price_id(stripe_sub)
      # Handle both real Stripe objects and OpenStruct mocks
      if stripe_sub.items.respond_to?(:data)
        items_data = stripe_sub.items.data
        if items_data.is_a?(Array) && items_data.first
          first_item = items_data.first
          if first_item.respond_to?(:price)
            price = first_item.price
            price.respond_to?(:id) ? price.id : nil
          end
        end
      end
    end

    def find_user_from_session(session)
      # Try to find by metadata first
      if session.metadata && session.metadata.respond_to?(:user_id) && session.metadata.user_id.present?
        User.find_by(id: session.metadata.user_id)
      elsif session.respond_to?(:[]) && session['metadata'] && session['metadata']['user_id'].present?
        User.find_by(id: session['metadata']['user_id'])
      elsif session.customer.present?
        find_user_by_customer(session.customer)
      end
    end

    def find_user_by_customer(customer_id)
      User.find_by(stripe_customer_id: customer_id)
    end

    def map_stripe_status(stripe_status)
      case stripe_status
      when 'active', 'trialing'
        'active'
      when 'past_due', 'unpaid'
        'past_due'
      when 'canceled', 'incomplete_expired'
        'canceled'
      else
        'pending'
      end
    end

    def stripe_service
      @stripe_service ||= StripeService.new
    end

    def log_webhook_error(message, error)
      Rails.logger.error "Stripe webhook error: #{message} - #{error.message}"
      SystemLog.log_error(
        'stripe_webhook_error',
        description: message,
        metadata: { error: error.message, error_class: error.class.name }
      )
    end

    def log_missing_user(event_type, object)
      object_id = object.respond_to?(:id) ? object.id : object['id']
      customer_id = object.respond_to?(:customer) ? object.customer : object['customer']
      
      Rails.logger.warn "Stripe webhook: No user found for #{event_type} - object_id: #{object_id}, customer: #{customer_id}"
      SystemLog.log_warning(
        'stripe_webhook_user_not_found',
        description: "No user found for Stripe event #{event_type}",
        metadata: { event_type: event_type, object_id: object_id, customer_id: customer_id }
      )
    end
  end
end
