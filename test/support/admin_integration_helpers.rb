# frozen_string_literal: true

# Helpers pour les tests d'interface Admin (Devise scope :admin =e AdminUser)
# IMPORTANT: le devise_mapping (devise_for :admins ...) donne resource_name=:admin
# donc les params attendus sont { admin: { email, password } }.
module AdminIntegrationHelpers
  def sign_in_admin(admin = admins(:admin_one), password: 'password123')
    post admin_session_path, params: {
      admin: {
        email: admin.email,
        password: password
      }
    }
    follow_redirect! if response.redirect?
    admin
  end

  def sign_out_admin
    delete destroy_admin_session_path
    follow_redirect! if response.redirect?
  end
end
