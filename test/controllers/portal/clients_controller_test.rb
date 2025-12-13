# frozen_string_literal: true

require "test_helper"

class ClientClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:active_user)
    @artisan_client = clients(:client_acme)
    @other_user = users(:turkish_user)
    @other_client = clients(:client_turkish)
  end

  # ===== Authentication Tests =====

  test "index redirects when not authenticated" do
    get client_clients_path
    assert_redirected_to root_path
  end

  test "show redirects when not authenticated" do
    get client_client_path(@artisan_client)
    assert_redirected_to root_path
  end

  # ===== Index Tests =====

  test "index shows user clients" do
    login_via_signed_url(@user)
    
    get client_clients_path
    assert_response :success
    assert_select "h3", text: @artisan_client.name
  end

  test "index does not show other user clients" do
    login_via_signed_url(@user)
    
    get client_clients_path
    assert_response :success
    assert_select "h3", text: @other_client.name, count: 0
  end

  test "index search works" do
    login_via_signed_url(@user)
    
    get client_clients_path(search: "ACME")
    assert_response :success
    assert_select "h3", text: @artisan_client.name
  end

  test "index shows empty state when no clients" do
    new_user = User.create!(
      phone_number: "+33699887766",
      subscription_status: "active"
    )
    
    login_via_signed_url(new_user)
    
    get client_clients_path
    assert_response :success
    assert_match(/Aucun client/, response.body)
  end

  # ===== Show Tests =====

  test "show displays client details" do
    login_via_signed_url(@user)
    
    get client_client_path(@artisan_client)
    assert_response :success
    assert_select "h2", text: @artisan_client.name
  end

  test "show returns 404 for other user client" do
    login_via_signed_url(@user)
    
    get client_client_path(@other_client)
    assert_redirected_to client_clients_path
    follow_redirect!
    assert_match(/non trouvé/, flash[:alert])
  end

  test "show displays client stats" do
    login_via_signed_url(@user)
    
    get client_client_path(@artisan_client)
    assert_response :success
    assert_select ".text-2xl.font-bold"
  end

  test "show displays recent quotes for client" do
    login_via_signed_url(@user)
    
    get client_client_path(@artisan_client)
    assert_response :success
    assert_select "a[href*='quotes']"
  end

  test "show displays recent invoices for client" do
    login_via_signed_url(@user)
    
    get client_client_path(@artisan_client)
    assert_response :success
    assert_select "a[href*='invoices']"
  end

  private

  def login_via_signed_url(user)
    token = SignedUrlService.generate_token(user)
    get signed_user_access_path(token: token)
    follow_redirect! if response.redirect?
  end
end
