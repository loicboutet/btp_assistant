# frozen_string_literal: true

require "test_helper"

class StripeWebhookSubscriptionUpdateFlowTest < ActionDispatch::IntegrationTest
  include ExternalApiStubs

  setup do
    @user = users(:active_user)
    @user.update!(stripe_customer_id: "cus_active_456")

    AppSetting.instance.update!(
      stripe_secret_key: "sk_test_xxx",
      stripe_webhook_secret: "whsec_test_secret_123",
      stripe_price_id: "price_test_monthly"
    )

    @subscription = @user.subscriptions.create!(
      stripe_subscription_id: "sub_update_999",
      status: "active",
      cancel_at_period_end: false
    )
  end

  test "webhook Stripe customer.subscription.updated -> met à jour Subscription + user.subscription_status" do
    event = build_stripe_event(
      "customer.subscription.updated",
      {
        id: "sub_update_999",
        customer: @user.stripe_customer_id,
        status: "past_due",
        current_period_start: 1.month.ago.to_i,
        current_period_end: Time.current.to_i,
        cancel_at_period_end: true,
        items: OpenStruct.new(data: [OpenStruct.new(price: OpenStruct.new(id: "price_xxx"))])
      }
    )

    stub_stripe_verify_webhook(event)

    post webhooks_stripe_path, params: { any: "payload" }.to_json, headers: stripe_test_headers

    assert_response :ok
    assert_equal "past_due", @user.reload.subscription_status
    assert_equal "past_due", @subscription.reload.status
    assert @subscription.cancel_at_period_end
  end
end
