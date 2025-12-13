# frozen_string_literal: true

require "test_helper"

class AdminSettingsTest < AdminRequestTestCase
  test "GET /admin/settings is successful" do
    sign_in_admin

    get admin_settings_path
    assert_response :success

    assert_select "h1", /Paramètres de l'application/i
  end

  test "PATCH /admin/settings updates general settings" do
    sign_in_admin

    app_setting = AppSetting.instance
    old_value = app_setting.signed_url_expiration_minutes

    patch admin_settings_path, params: {
      app_setting: {
        signed_url_expiration_minutes: old_value + 1
      }
    }

    assert_redirected_to admin_settings_path
    app_setting.reload
    assert_equal old_value + 1, app_setting.signed_url_expiration_minutes
  end

  test "PATCH /admin/settings with invalid values renders 422" do
    sign_in_admin

    patch admin_settings_path, params: {
      app_setting: {
        signed_url_expiration_minutes: 0
      }
    }

    assert_response :unprocessable_entity
  end

  test "POST /admin/settings/test_connection returns json (stubbed)" do
    sign_in_admin

    # Aucun appel externe: on stub la méthode privée test_unipile
    Admin::SettingsController.any_instance.stubs(:test_unipile).returns({ ok: true, message: "Unipile OK" })

    post admin_settings_test_connection_path, params: { service: "unipile" }, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal true, body["success"]
    assert_equal "unipile", body["service"]
  end

  test "POST /admin/settings/test_connection stripe ok (fully stubbed)" do
    sign_in_admin

    Admin::SettingsController.any_instance.stubs(:test_stripe).returns({ ok: true, message: "Stripe OK" })

    post admin_settings_test_connection_path, params: { service: "stripe" }, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal true, body["success"]
    assert_equal "stripe", body["service"]
  end

  test "POST /admin/settings/test_connection openai ok (fully stubbed)" do
    sign_in_admin

    Admin::SettingsController.any_instance.stubs(:test_openai).returns({ ok: true, message: "OpenAI OK" })

    post admin_settings_test_connection_path, params: { service: "openai" }, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal true, body["success"]
    assert_equal "openai", body["service"]
  end
end
