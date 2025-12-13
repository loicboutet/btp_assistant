# frozen_string_literal: true

require "test_helper"

class Webhooks::StripeControllerTest < ActionDispatch::IntegrationTest
  include ExternalApiStubs

  setup do
    @user = users(:pending_user)
    @user.update!(stripe_customer_id: "cus_test_123")
    @active_user = users(:active_user)
    @active_user.update!(stripe_customer_id: "cus_active_456")

    # Setup AppSetting with test keys
    AppSetting.instance.update!(
      stripe_secret_key: "sk_test_xxx",
      stripe_webhook_secret: "whsec_test_secret_123",
      stripe_price_id: "price_test_monthly"
    )
  end

  # ========================================
  # Signature Verification Tests
  # ========================================

  test "returns bad_request for invalid signature" do
    # Ici on ne stubbe pas verify_webhook : le controller va appeler la vraie vérification
    # et doit renvoyer 400 en cas de signature invalide.
    post webhooks_stripe_path,
      params: '{}',
      headers: {
        'Content-Type' => 'application/json',
        'Stripe-Signature' => 'invalid_signature'
      }

    assert_response :bad_request
  end

  test "returns bad_request for missing signature" do
    post webhooks_stripe_path,
      params: '{}',
      headers: { 'Content-Type' => 'application/json' }

    assert_response :bad_request
  end

  # ========================================
  # checkout.session.completed Tests
  # ========================================

  test "handles checkout.session.completed and activates user" do
    event = build_stripe_event('checkout.session.completed', {
      id: 'cs_123',
      customer: @user.stripe_customer_id,
      metadata: OpenStruct.new(user_id: @user.id.to_s)
    })

    stub_stripe_verify_webhook(event)

    assert_equal 'pending', @user.subscription_status

    post webhooks_stripe_path,
      params: { any: 'payload' }.to_json,
      headers: stripe_test_headers

    assert_response :ok
    assert_equal 'active', @user.reload.subscription_status
  end

  test "handles checkout.session.completed by customer ID" do
    event = build_stripe_event('checkout.session.completed', {
      id: 'cs_124',
      customer: @user.stripe_customer_id,
      metadata: OpenStruct.new(user_id: nil)
    })

    stub_stripe_verify_webhook(event)

    post webhooks_stripe_path,
      params: { any: 'payload' }.to_json,
      headers: stripe_test_headers

    assert_response :ok
    assert_equal 'active', @user.reload.subscription_status
  end

  # ========================================
  # customer.subscription.created Tests
  # ========================================

  test "handles customer.subscription.created" do
    event = build_stripe_event('customer.subscription.created', {
      id: 'sub_new_123',
      customer: @user.stripe_customer_id,
      status: 'active',
      current_period_start: 1.day.ago.to_i,
      current_period_end: 1.month.from_now.to_i,
      cancel_at_period_end: false,
      items: OpenStruct.new(data: [
        OpenStruct.new(price: OpenStruct.new(id: 'price_test_monthly'))
      ])
    })

    stub_stripe_verify_webhook(event)

    assert_difference '@user.subscriptions.count', 1 do
      post webhooks_stripe_path,
        params: { any: 'payload' }.to_json,
        headers: stripe_test_headers
    end

    assert_response :ok
    subscription = @user.subscriptions.last
    assert_equal 'sub_new_123', subscription.stripe_subscription_id
    assert_equal 'active', subscription.status
  end

  # ========================================
  # customer.subscription.updated Tests
  # ========================================

  test "handles customer.subscription.updated to past_due" do
    subscription = @active_user.subscriptions.create!(
      stripe_subscription_id: 'sub_update_123',
      status: 'active'
    )

    event = build_stripe_event('customer.subscription.updated', {
      id: 'sub_update_123',
      customer: @active_user.stripe_customer_id,
      status: 'past_due',
      current_period_start: 1.month.ago.to_i,
      current_period_end: Time.current.to_i,
      cancel_at_period_end: false,
      items: OpenStruct.new(data: [
        OpenStruct.new(price: OpenStruct.new(id: 'price_xxx'))
      ])
    })

    stub_stripe_verify_webhook(event)

    post webhooks_stripe_path,
      params: { any: 'payload' }.to_json,
      headers: stripe_test_headers

    assert_response :ok
    assert_equal 'past_due', @active_user.reload.subscription_status
    assert_equal 'past_due', subscription.reload.status
  end

  test "handles subscription updated with cancel_at_period_end" do
    subscription = @active_user.subscriptions.create!(
      stripe_subscription_id: 'sub_cancel_123',
      status: 'active'
    )

    event = build_stripe_event('customer.subscription.updated', {
      id: 'sub_cancel_123',
      customer: @active_user.stripe_customer_id,
      status: 'active',
      current_period_start: 1.month.ago.to_i,
      current_period_end: 1.month.from_now.to_i,
      cancel_at_period_end: true,
      items: OpenStruct.new(data: [
        OpenStruct.new(price: OpenStruct.new(id: 'price_xxx'))
      ])
    })

    stub_stripe_verify_webhook(event)

    post webhooks_stripe_path,
      params: { any: 'payload' }.to_json,
      headers: stripe_test_headers

    assert_response :ok
    assert subscription.reload.cancel_at_period_end
  end

  # ========================================
  # customer.subscription.deleted Tests
  # ========================================

  test "handles customer.subscription.deleted" do
    subscription = @active_user.subscriptions.create!(
      stripe_subscription_id: 'sub_delete_123',
      status: 'active'
    )
    @active_user.update!(subscription_status: 'active')

    event = build_stripe_event('customer.subscription.deleted', {
      id: 'sub_delete_123',
      customer: @active_user.stripe_customer_id
    })

    stub_stripe_verify_webhook(event)

    post webhooks_stripe_path,
      params: { any: 'payload' }.to_json,
      headers: stripe_test_headers

    assert_response :ok
    assert_equal 'canceled', @active_user.reload.subscription_status
    assert_equal 'canceled', subscription.reload.status
    assert_not_nil subscription.canceled_at
  end

  # ========================================
  # invoice.paid Tests
  # ========================================

  test "handles invoice.paid" do
    subscription = @active_user.subscriptions.create!(
      stripe_subscription_id: 'sub_invoice_123',
      status: 'active'
    )

    event = build_stripe_event('invoice.paid', {
      id: 'in_test_123',
      customer: @active_user.stripe_customer_id,
      subscription: 'sub_invoice_123',
      number: 'INV-001',
      amount_paid: 2990,
      currency: 'eur',
      period_start: 1.month.ago.to_i,
      period_end: Time.current.to_i,
      hosted_invoice_url: 'https://invoice.stripe.com/xxx',
      invoice_pdf: 'https://invoice.stripe.com/xxx.pdf'
    })

    stub_stripe_verify_webhook(event)

    assert_difference '@active_user.subscription_invoices.count', 1 do
      post webhooks_stripe_path,
        params: { any: 'payload' }.to_json,
        headers: stripe_test_headers
    end

    assert_response :ok

    invoice = @active_user.subscription_invoices.last
    assert_equal 'in_test_123', invoice.stripe_invoice_id
    assert_equal 'INV-001', invoice.invoice_number
    assert_equal 29.90, invoice.amount
    assert_equal 'eur', invoice.currency
    assert_equal 'paid', invoice.status
  end

  test "invoice.paid is idempotent - skips duplicate" do
    subscription = @active_user.subscriptions.create!(
      stripe_subscription_id: 'sub_dup_123',
      status: 'active'
    )

    # Create existing invoice
    @active_user.subscription_invoices.create!(
      stripe_invoice_id: 'in_duplicate_123',
      subscription: subscription,
      status: 'paid',
      amount: 29.90
    )

    event = build_stripe_event('invoice.paid', {
      id: 'in_duplicate_123',
      customer: @active_user.stripe_customer_id,
      subscription: 'sub_dup_123',
      number: 'INV-002',
      amount_paid: 2990,
      currency: 'eur',
      period_start: 1.month.ago.to_i,
      period_end: Time.current.to_i
    })

    stub_stripe_verify_webhook(event)

    assert_no_difference '@active_user.subscription_invoices.count' do
      post webhooks_stripe_path,
        params: { any: 'payload' }.to_json,
        headers: stripe_test_headers
    end

    assert_response :ok
  end

  test "invoice.paid skips non-subscription invoices" do
    event = build_stripe_event('invoice.paid', {
      id: 'in_one_time_123',
      customer: @active_user.stripe_customer_id,
      subscription: nil,
      number: 'ONE-001',
      amount_paid: 5000
    })

    stub_stripe_verify_webhook(event)

    assert_no_difference '@active_user.subscription_invoices.count' do
      post webhooks_stripe_path,
        params: { any: 'payload' }.to_json,
        headers: stripe_test_headers
    end

    assert_response :ok
  end

  # ========================================
  # invoice.payment_failed Tests
  # ========================================

  test "handles invoice.payment_failed" do
    @active_user.update!(subscription_status: 'active')

    event = build_stripe_event('invoice.payment_failed', {
      id: 'in_failed_123',
      customer: @active_user.stripe_customer_id,
      attempt_count: 1
    })

    stub_stripe_verify_webhook(event)

    post webhooks_stripe_path,
      params: { any: 'payload' }.to_json,
      headers: stripe_test_headers

    assert_response :ok
    assert_equal 'past_due', @active_user.reload.subscription_status
  end

  # ========================================
  # Unhandled Event Tests
  # ========================================

  test "returns ok for unhandled event types" do
    event = build_stripe_event('customer.created', { id: 'cus_xxx' })

    stub_stripe_verify_webhook(event)

    post webhooks_stripe_path,
      params: { any: 'payload' }.to_json,
      headers: stripe_test_headers

    assert_response :ok
  end

  # ========================================
  # Error Handling Tests
  # ========================================

  test "logs warning when user not found" do
    event = build_stripe_event('checkout.session.completed', {
      id: 'cs_orphan_123',
      customer: 'cus_nonexistent',
      metadata: OpenStruct.new(user_id: nil)
    })

    stub_stripe_verify_webhook(event)

    assert_difference 'SystemLog.count', 1 do
      post webhooks_stripe_path,
        params: { any: 'payload' }.to_json,
        headers: stripe_test_headers
    end

    assert_response :ok
    log = SystemLog.last
    assert_equal 'stripe_webhook_user_not_found', log.event
  end
end
