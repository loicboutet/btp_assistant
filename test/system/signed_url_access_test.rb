# frozen_string_literal: true

require "application_system_test_case"

class SignedUrlAccessTest < ApplicationSystemTestCase
  test "signed URL crée une session et redirige vers /dashboard" do
    user = users(:active_user)

    token = SignedUrlService.generate_token(user)
    visit signed_user_access_path(token: token)

    assert_current_path client_dashboard_path

    # Vérifie qu'on est bien sur la zone client (dashboard)
    assert_text "Mes devis"
    assert_text "Mes factures"
    assert_text "Mes clients"

    # Vérifie qu'on reste authentifié via session sur une autre page
    visit client_profile_path
    assert_current_path client_profile_path
  end
end
