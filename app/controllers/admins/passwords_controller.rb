# frozen_string_literal: true

class Admins::PasswordsController < Devise::PasswordsController
  layout 'devise'

  protected

  def after_resetting_password_path_for(resource)
    admin_dashboard_path
  end
end
