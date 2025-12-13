# frozen_string_literal: true

require "test_helper"

class AdminSubscriptionsTest < AdminRequestTestCase
  test "index lists subscriptions" do
    sign_in_admin

    get admin_subscriptions_path
    assert_response :success

    assert_select "h1", /Gestion des abonnements/i
    assert_match subscriptions(:active_subscription).stripe_subscription_id, response.body
  end

  test "index supports q search" do
    sign_in_admin

    get admin_subscriptions_path, params: { q: "sub_active" }
    assert_response :success
    assert_match "sub_active_123", response.body
  end

  test "show displays a subscription" do
    sign_in_admin

    sub = subscriptions(:active_subscription)
    get admin_subscription_path(sub)

    assert_response :success
    assert_match sub.stripe_subscription_id, response.body
  end

  test "overdue lists past_due subscriptions" do
    sign_in_admin

    get overdue_admin_subscriptions_path
    assert_response :success

    assert_match subscriptions(:past_due_subscription).stripe_subscription_id, response.body
  end
end
