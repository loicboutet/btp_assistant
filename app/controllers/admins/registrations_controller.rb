# frozen_string_literal: true

class Admins::RegistrationsController < Devise::RegistrationsController
  layout 'devise'

  # In production, you might want to disable admin registration
  # before_action :check_registration_enabled, only: [:new, :create]

  protected

  def after_sign_up_path_for(resource)
    admin_dashboard_path
  end

  def after_update_path_for(resource)
    admin_dashboard_path
  end

  # private

  # def check_registration_enabled
  #   unless AppSetting.admin_registration_enabled?
  #     redirect_to new_admin_session_path, alert: "Admin registration is currently disabled."
  #   end
  # end
end
