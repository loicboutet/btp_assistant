# frozen_string_literal: true

require "test_helper"

class SignedUrlDashboardFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:active_user)
  end

  test "signed URL -> crée session -> redirect dashboard -> session persiste" do
    token = SignedUrlService.generate_token(@user)

    # 1) Entrée via lien signé
    get signed_user_access_path(token: token)
    assert_redirected_to client_dashboard_path

    follow_redirect!
    assert_response :success

    # On vérifie que la page dashboard est bien rendue et qu'on a accès aux liens clés
    assert_select "a[href=?]", client_quotes_path
    assert_select "a[href=?]", client_invoices_path
    assert_select "a[href=?]", client_clients_path

    # 2) Vérifie que la session permet d'accéder à une autre page Portal::
    get client_profile_path
    assert_response :success
  end
end
