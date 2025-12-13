# frozen_string_literal: true

require "test_helper"

class AdminSystemLogsTest < AdminRequestTestCase
  test "index lists logs" do
    sign_in_admin

    SystemLog.log_info("event_x", description: "desc")

    get admin_system_logs_path
    assert_response :success

    assert_select "h1", /Logs système/i
    assert_match "event_x", response.body
  end

  test "index supports filters" do
    sign_in_admin

    SystemLog.log_warning("warning_event", description: "something")

    get admin_system_logs_path, params: { log_type: "warning" }
    assert_response :success
    assert_match "warning_event", response.body
  end

  test "index supports q search (results table)" do
    sign_in_admin

    SystemLog.log_info("event_search_hit", description: "something unique")
    SystemLog.log_info("event_search_miss", description: "other")

    get admin_system_logs_path, params: { q: "unique" }
    assert_response :success

    # NB: la page contient aussi la liste des events pour le filtre, donc on vérifie
    # uniquement le tableau des résultats.
    assert_select "table.admin-table tbody" do
      assert_select "tr", text: /event_search_hit/
      assert_select "tr", text: /event_search_miss/, count: 0
    end
  end

  test "show displays a log" do
    sign_in_admin

    log = SystemLog.log_audit("audit_event", description: "audit")

    get admin_system_log_path(log)
    assert_response :success
    assert_match "audit_event", response.body
  end
end
