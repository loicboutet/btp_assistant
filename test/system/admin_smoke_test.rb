# frozen_string_literal: true

require "application_system_test_case"

class AdminSmokeTest < ApplicationSystemTestCase
  test "admin can login and access settings" do
    admin = admins(:admin_one)

    visit new_admin_session_path

    fill_in "Adresse e-mail", with: admin.email
    fill_in "Mot de passe", with: "password123"

    click_button "Se connecter"

    assert_current_path admin_dashboard_path

    # Navigate to settings
    visit admin_settings_path
    assert_text "Paramètres"

    # Navigate to OpenAI settings page
    visit admin_settings_openai_path
    assert_text "OpenAI"
  end
end
