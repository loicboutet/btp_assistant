# frozen_string_literal: true

require "test_helper"

class AdminSystemLogsAuthTest < ActionDispatch::IntegrationTest
  test "system_logs require authentication" do
    get admin_system_logs_path
    assert_redirected_to new_admin_session_path
  end

  test "system_logs show requires authentication" do
    log = SystemLog.log_info("event_auth", description: "desc")

    get admin_system_log_path(log)
    assert_redirected_to new_admin_session_path
  end
end
