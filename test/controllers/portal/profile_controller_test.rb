# frozen_string_literal: true

require "test_helper"

class ClientProfileControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:active_user)
    @user.update!(stripe_customer_id: "cus_test123")

    # Ensure StripeService can initialize in parallel test workers
    AppSetting.instance.update!(stripe_secret_key: "sk_test_123")
  end

  # ===== Authentication Tests =====

  test "show redirects when not authenticated" do
    get client_profile_path
    assert_redirected_to root_path
  end

  test "update redirects when not authenticated" do
    patch client_profile_path, params: { user: { company_name: "New Name" } }
    assert_redirected_to root_path
  end

  # ===== Show Tests =====

  test "show displays profile" do
    login_via_signed_url(@user)

    get client_profile_path
    assert_response :success
    assert_select "h2", text: @user.display_name
  end

  test "show displays subscription status" do
    login_via_signed_url(@user)

    get client_profile_path
    assert_response :success
    assert_select ".text-green-600", /Actif/
  end

  test "show displays subscription invoices" do
    @user.subscription_invoices.create!(
      stripe_invoice_id: "inv_test123",
      amount: 29.99,
      status: "paid",
      period_start: Date.current.beginning_of_month,
      period_end: Date.current.end_of_month
    )

    login_via_signed_url(@user)

    get client_profile_path
    assert_response :success
    assert_match(/29,99/, response.body)
  end

  test "show displays manage subscription button when stripe customer exists" do
    login_via_signed_url(@user)

    get client_profile_path
    assert_response :success
    assert_select "button", text: /Gérer mon abonnement/
  end

  # ===== Update Tests =====

  test "update changes company name" do
    login_via_signed_url(@user)

    patch client_profile_path, params: { user: { company_name: "New Company Name" } }
    assert_redirected_to client_profile_path

    @user.reload
    assert_equal "New Company Name", @user.company_name
  end

  test "update changes address" do
    login_via_signed_url(@user)

    patch client_profile_path, params: { user: { address: "New Address, Paris" } }
    assert_redirected_to client_profile_path

    @user.reload
    assert_equal "New Address, Paris", @user.address
  end

  test "update changes preferred language" do
    login_via_signed_url(@user)

    patch client_profile_path, params: { user: { preferred_language: "tr" } }
    assert_redirected_to client_profile_path

    @user.reload
    assert_equal "tr", @user.preferred_language
  end

  test "update rejects invalid preferred language" do
    login_via_signed_url(@user)

    patch client_profile_path, params: { user: { preferred_language: "invalid" } }
    assert_response :unprocessable_entity
  end

  # ===== Billing Portal Tests =====

  test "billing portal redirects to stripe" do
    login_via_signed_url(@user)

    mock_session = Minitest::Mock.new
    mock_session.expect :url, "https://billing.stripe.com/portal/test"

    StripeService.any_instance.expects(:create_portal_session)
      .with(user: @user, return_url: client_profile_url)
      .returns(mock_session)

    post client_billing_portal_path
    assert_redirected_to "https://billing.stripe.com/portal/test"
  end

  test "billing portal handles stripe errors" do
    login_via_signed_url(@user)

    StripeService.any_instance.expects(:create_portal_session)
      .raises(StripeService::ApiError.new("Stripe error"))

    post client_billing_portal_path
    assert_redirected_to client_profile_path
    follow_redirect!
    assert_match(/portail/, flash[:alert])
  end

  test "billing portal fails when no stripe customer" do
    @user.update!(stripe_customer_id: nil)
    login_via_signed_url(@user)

    StripeService.any_instance.expects(:create_portal_session)
      .raises(StripeService::Error.new("No customer"))

    post client_billing_portal_path
    assert_redirected_to client_profile_path
  end

  private

  def login_via_signed_url(user)
    token = SignedUrlService.generate_token(user)
    get signed_user_access_path(token: token)
    follow_redirect! if response.redirect?
  end
end
