# frozen_string_literal: true

require "test_helper"

class AdminLogsAliasTest < AdminRequestTestCase
  test "GET /admin/logs maps to SystemLogsController#index" do
    sign_in_admin

    SystemLog.log_info("event_alias", description: "desc")

    get admin_logs_path
    assert_response :success
    assert_select "h1", /Logs système/i
    assert_match "event_alias", response.body
  end

  test "GET /admin/logs/:id maps to SystemLogsController#show" do
    sign_in_admin

    log = SystemLog.log_audit("event_alias_show", description: "desc")

    get admin_log_path(log)
    assert_response :success
    assert_match "event_alias_show", response.body
  end
end
