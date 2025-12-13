# frozen_string_literal: true

require "test_helper"

class ClientDashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:active_user)
  end

  test "redirects to root when not authenticated" do
    get client_dashboard_path
    assert_redirected_to root_path
  end

  test "shows dashboard for authenticated user" do
    login_via_signed_url(@user)
    
    get client_dashboard_path
    assert_response :success
  end

  test "displays stats correctly" do
    login_via_signed_url(@user)
    
    get client_dashboard_path
    assert_response :success
    
    # Should have the navigation cards
    assert_select "a[href=?]", client_quotes_path
    assert_select "a[href=?]", client_invoices_path
    assert_select "a[href=?]", client_clients_path
  end

  test "shows correct quote count" do
    login_via_signed_url(@user)
    
    get client_dashboard_path
    assert_response :success
    
    # User has 2 quotes from fixtures
    assert_select "span.bg-green-100", /\d+/
  end

  test "session expires after 2 hours" do
    login_via_signed_url(@user)
    
    # Travel 3 hours into the future
    travel 3.hours do
      get client_dashboard_path
      assert_redirected_to root_path
    end
  end

  test "refreshes session on access within 2 hours" do
    login_via_signed_url(@user)
    
    # Travel 1 hour
    travel 1.hour do
      get client_dashboard_path
      assert_response :success
    end
  end

  private

  def login_via_signed_url(user)
    token = SignedUrlService.generate_token(user)
    get signed_user_access_path(token: token)
    assert_redirected_to client_dashboard_path
    follow_redirect!
  end
end
