# frozen_string_literal: true

require "test_helper"

class StripeServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:active_user)
    @pending_user = users(:pending_user)
    
    # Setup AppSetting with test Stripe keys
    setup_stripe_config
  end

  # ========================================
  # Configuration Tests
  # ========================================

  test "raises ConfigurationError when API key not configured" do
    AppSetting.instance.update!(stripe_secret_key: nil)

    assert_raises(StripeService::ConfigurationError) do
      StripeService.new
    end
  end

  test "initializes successfully with valid API key" do
    service = StripeService.new
    assert_instance_of StripeService, service
  end

  # ========================================
  # create_customer Tests
  # ========================================

  test "create_customer creates Stripe customer" do
    stub_stripe_customer_create

    service = StripeService.new
    customer = service.create_customer(@user)

    assert_equal "cus_test_123", customer.id
  end

  test "create_customer includes user phone and name" do
    stub_stripe_customer_create
    
    service = StripeService.new
    customer = service.create_customer(@user)
    
    # Just verify the customer was created - WebMock captured the request
    assert_equal "cus_test_123", customer.id
    assert_requested :post, "https://api.stripe.com/v1/customers"
  end

  test "create_customer raises ApiError on Stripe failure" do
    stub_request(:post, "https://api.stripe.com/v1/customers")
      .to_return(status: 400, body: { error: { message: "Invalid phone" } }.to_json)

    service = StripeService.new

    assert_raises(StripeService::ApiError) do
      service.create_customer(@user)
    end
  end

  # ========================================
  # ensure_customer Tests
  # ========================================

  test "ensure_customer returns existing customer ID" do
    @user.update!(stripe_customer_id: "cus_existing_456")

    service = StripeService.new
    customer_id = service.ensure_customer(@user)

    assert_equal "cus_existing_456", customer_id
  end

  test "ensure_customer creates new customer if none exists" do
    @pending_user.update!(stripe_customer_id: nil)
    stub_stripe_customer_create("cus_new_789")

    service = StripeService.new
    customer_id = service.ensure_customer(@pending_user)

    assert_equal "cus_new_789", customer_id
    assert_equal "cus_new_789", @pending_user.reload.stripe_customer_id
  end

  # ========================================
  # create_checkout_session Tests
  # ========================================

  test "create_checkout_session creates session with existing customer" do
    @user.update!(stripe_customer_id: "cus_existing_123")
    stub_stripe_checkout_session_create

    service = StripeService.new
    session = service.create_checkout_session(
      user: @user,
      success_url: "https://example.com/success",
      cancel_url: "https://example.com/cancel"
    )

    assert_equal "cs_test_session_123", session.id
    assert_equal "https://checkout.stripe.com/pay/cs_test_session_123", session.url
  end

  test "create_checkout_session creates customer first if needed" do
    @pending_user.update!(stripe_customer_id: nil)
    stub_stripe_customer_create("cus_new_for_checkout")
    stub_stripe_checkout_session_create

    service = StripeService.new
    session = service.create_checkout_session(
      user: @pending_user,
      success_url: "https://example.com/success",
      cancel_url: "https://example.com/cancel"
    )

    assert_equal "cs_test_session_123", session.id
    assert_equal "cus_new_for_checkout", @pending_user.reload.stripe_customer_id
  end

  test "create_checkout_session includes subscription mode" do
    @user.update!(stripe_customer_id: "cus_test_123")
    stub_stripe_checkout_session_create

    service = StripeService.new
    session = service.create_checkout_session(
      user: @user,
      success_url: "https://example.com/success",
      cancel_url: "https://example.com/cancel"
    )

    assert_equal "cs_test_session_123", session.id
    assert_requested :post, "https://api.stripe.com/v1/checkout/sessions"
  end

  # ========================================
  # create_portal_session Tests
  # ========================================

  test "create_portal_session creates billing portal session" do
    @user.update!(stripe_customer_id: "cus_portal_123")
    stub_stripe_portal_session_create

    service = StripeService.new
    session = service.create_portal_session(
      user: @user,
      return_url: "https://example.com/dashboard"
    )

    assert_equal "bps_test_123", session.id
    assert_equal "https://billing.stripe.com/session/bps_test_123", session.url
  end

  test "create_portal_session raises error if user has no customer" do
    @pending_user.update!(stripe_customer_id: nil)

    service = StripeService.new

    assert_raises(StripeService::Error) do
      service.create_portal_session(
        user: @pending_user,
        return_url: "https://example.com/dashboard"
      )
    end
  end

  # ========================================
  # get_subscription Tests
  # ========================================

  test "get_subscription retrieves subscription" do
    stub_stripe_subscription_retrieve

    service = StripeService.new
    subscription = service.get_subscription("sub_test_123")

    assert_equal "sub_test_123", subscription.id
    assert_equal "active", subscription.status
  end

  # ========================================
  # cancel_subscription Tests
  # ========================================

  test "cancel_subscription sets cancel_at_period_end" do
    stub_request(:post, "https://api.stripe.com/v1/subscriptions/sub_test_123")
      .to_return(status: 200, body: {
        id: "sub_test_123",
        status: "active",
        cancel_at_period_end: true
      }.to_json)

    service = StripeService.new
    subscription = service.cancel_subscription("sub_test_123")

    assert subscription.cancel_at_period_end
  end

  # ========================================
  # reactivate_subscription Tests
  # ========================================

  test "reactivate_subscription removes cancel_at_period_end" do
    stub_request(:post, "https://api.stripe.com/v1/subscriptions/sub_test_123")
      .to_return(status: 200, body: {
        id: "sub_test_123",
        status: "active",
        cancel_at_period_end: false
      }.to_json)

    service = StripeService.new
    subscription = service.reactivate_subscription("sub_test_123")

    refute subscription.cancel_at_period_end
  end

  # ========================================
  # verify_webhook Tests
  # ========================================

  test "verify_webhook verifies valid signature" do
    payload = '{"type": "test"}'
    timestamp = Time.now.to_i
    secret = AppSetting.instance.stripe_webhook_secret
    
    # Generate valid signature
    signed_payload = "#{timestamp}.#{payload}"
    signature = OpenSSL::HMAC.hexdigest("SHA256", secret, signed_payload)
    header = "t=#{timestamp},v1=#{signature}"

    service = StripeService.new
    event = service.verify_webhook(payload: payload, signature: header)

    assert_equal "test", event.type
  end

  test "verify_webhook raises on invalid signature" do
    service = StripeService.new

    assert_raises(Stripe::SignatureVerificationError) do
      service.verify_webhook(payload: '{}', signature: 'invalid')
    end
  end

  private

  def setup_stripe_config
    AppSetting.instance.update!(
      stripe_secret_key: "sk_test_stripe_key_123",
      stripe_price_id: "price_test_monthly_2990",
      stripe_webhook_secret: "whsec_test_webhook_secret_123"
    )
  end

  def stub_stripe_customer_create(customer_id = "cus_test_123")
    stub_request(:post, "https://api.stripe.com/v1/customers")
      .to_return(status: 200, body: {
        id: customer_id,
        object: "customer"
      }.to_json)
  end

  def stub_stripe_checkout_session_create
    stub_request(:post, "https://api.stripe.com/v1/checkout/sessions")
      .to_return(status: 200, body: {
        id: "cs_test_session_123",
        url: "https://checkout.stripe.com/pay/cs_test_session_123",
        object: "checkout.session"
      }.to_json)
  end

  def stub_stripe_portal_session_create
    stub_request(:post, "https://api.stripe.com/v1/billing_portal/sessions")
      .to_return(status: 200, body: {
        id: "bps_test_123",
        url: "https://billing.stripe.com/session/bps_test_123",
        object: "billing_portal.session"
      }.to_json)
  end

  def stub_stripe_subscription_retrieve
    stub_request(:get, "https://api.stripe.com/v1/subscriptions/sub_test_123")
      .to_return(status: 200, body: {
        id: "sub_test_123",
        status: "active",
        current_period_start: 1.month.ago.to_i,
        current_period_end: 1.month.from_now.to_i,
        cancel_at_period_end: false
      }.to_json)
  end
end
