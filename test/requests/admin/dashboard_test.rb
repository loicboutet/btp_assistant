# frozen_string_literal: true

require "test_helper"

class AdminDashboardTest < AdminRequestTestCase
  test "GET /admin is successful for authenticated admin" do
    sign_in_admin

    get admin_dashboard_path
    assert_response :success

    assert_select "h1", /Tableau de bord Admin/i
  end

  test "GET /admin/metrics is successful" do
    sign_in_admin

    get admin_metrics_path
    assert_response :success
  end
end
