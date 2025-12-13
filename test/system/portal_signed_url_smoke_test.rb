# frozen_string_literal: true

require "application_system_test_case"

class PortalSignedUrlSmokeTest < ApplicationSystemTestCase
  test "signed URL creates a session and allows browsing portal" do
    user = users(:active_user)
    token = SignedUrlService.generate_token(user)

    visit signed_user_access_path(token: token)

    assert_current_path client_dashboard_path
    assert_text "Mes devis"

    visit client_quotes_path
    assert_current_path client_quotes_path

    # La page liste contient des devis (numérotation DEVIS-YYYY-NNNN)
    assert_text "DEVIS-"
  end
end
