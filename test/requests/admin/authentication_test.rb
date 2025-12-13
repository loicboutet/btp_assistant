# frozen_string_literal: true

require "test_helper"

class AdminAuthenticationTest < ActionDispatch::IntegrationTest
  include AdminIntegrationHelpers

  test "GET /admin requires authentication" do
    get admin_dashboard_path
    assert_redirected_to new_admin_session_path
  end

  test "admin can login and access dashboard" do
    admin = admins(:admin_one)

    post admin_session_path, params: {
      admin: {
        email: admin.email,
        password: "password123"
      }
    }

    assert_redirected_to admin_dashboard_path
    follow_redirect!
    assert_response :success

    assert_select "h1", /Tableau de bord Admin/i
  end

  test "admin login fails with wrong password" do
    admin = admins(:admin_one)

    post admin_session_path, params: {
      admin: {
        email: admin.email,
        password: "wrong"
      }
    }

    assert_response :unprocessable_entity
  end
end
