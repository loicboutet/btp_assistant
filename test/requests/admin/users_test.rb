# frozen_string_literal: true

require "test_helper"

class AdminUsersTest < AdminRequestTestCase
  test "index lists users" do
    sign_in_admin

    get admin_users_path
    assert_response :success

    assert_select "h1", /Gestion des Utilisateurs/i
    assert_match users(:active_user).display_name, response.body
  end

  test "index supports search" do
    sign_in_admin

    get admin_users_path, params: { q: "Active" }
    assert_response :success
    assert_match "Entreprise Active", response.body
  end

  test "show displays a user" do
    sign_in_admin

    user = users(:active_user)
    get admin_user_path(user)

    assert_response :success
    assert_match user.display_name, response.body
  end

  test "GET new renders" do
    sign_in_admin

    get new_admin_user_path
    assert_response :success
  end

  test "POST create creates a user (minimal required attrs)" do
    sign_in_admin

    assert_difference("User.count", +1) do
      post admin_users_path, params: {
        user: {
          phone_number: "+33600000001",
          company_name: "Nouvelle Entreprise",
          preferred_language: "fr",
          account_status: "active"
        }
      }
    end

    created = User.order(:id).last
    assert_redirected_to admin_user_path(created)
    assert_equal "active", created.subscription_status
  end

  test "POST create with invalid params renders 422" do
    sign_in_admin

    assert_no_difference("User.count") do
      post admin_users_path, params: { user: { phone_number: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "GET edit renders" do
    sign_in_admin

    user = users(:active_user)
    get edit_admin_user_path(user)
    assert_response :success
  end

  test "PATCH update updates user attributes and account_status mapping" do
    sign_in_admin

    user = users(:active_user)

    patch admin_user_path(user), params: {
      user: {
        company_name: "Entreprise Modifiée",
        account_status: "suspended"
      }
    }

    assert_redirected_to admin_user_path(user)
    user.reload
    assert_equal "Entreprise Modifiée", user.company_name
    assert_equal "canceled", user.subscription_status
  end

  test "POST suspend updates subscription_status" do
    sign_in_admin

    user = users(:active_user)
    post suspend_admin_user_path(user)

    assert_redirected_to admin_user_path(user)
    user.reload
    assert_equal "canceled", user.subscription_status
  end

  test "POST activate updates subscription_status" do
    sign_in_admin

    user = users(:canceled_user)
    post activate_admin_user_path(user)

    assert_redirected_to admin_user_path(user)
    user.reload
    assert_equal "active", user.subscription_status
  end

  test "POST reset_whatsapp clears unipile ids" do
    sign_in_admin

    user = users(:active_user)
    assert_not_nil user.unipile_chat_id

    post reset_whatsapp_admin_user_path(user)

    assert_redirected_to admin_user_path(user)
    user.reload
    assert_nil user.unipile_chat_id
    assert_nil user.unipile_attendee_id
  end

  test "GET /admin/users/:id/logs shows logs" do
    sign_in_admin

    user = users(:active_user)
    SystemLog.log_info("custom_event", description: "hello", user: user)

    get logs_admin_user_path(user)
    assert_response :success
    assert_match "custom_event", response.body
  end

  test "POST create_stripe_portal redirects to session url (stubbed)" do
    sign_in_admin

    # Evite le ConfigurationError dans StripeService#initialize
    AppSetting.instance.update!(stripe_secret_key: "sk_test_123")

    user = users(:active_user)
    user.update!(stripe_customer_id: "cus_test_123")

    fake_session = Struct.new(:url).new("https://billing.stripe.com/session/test")
    StripeService.any_instance.stubs(:create_portal_session).returns(fake_session)

    post create_stripe_portal_admin_user_path(user)

    assert_response :redirect
    assert_equal "https://billing.stripe.com/session/test", response.headers["Location"]
  end

  test "POST create_stripe_portal handles StripeService::Error" do
    sign_in_admin

    AppSetting.instance.update!(stripe_secret_key: "sk_test_123")

    user = users(:active_user)
    user.update!(stripe_customer_id: "cus_test_123")

    StripeService.any_instance.stubs(:create_portal_session).raises(StripeService::Error.new("boom"))

    post create_stripe_portal_admin_user_path(user)

    assert_redirected_to stripe_portal_admin_user_path(user)
    assert_match "Erreur Stripe", flash[:alert]
  end
end
