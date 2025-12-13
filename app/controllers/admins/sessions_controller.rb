# frozen_string_literal: true

class Admins::SessionsController < Devise::SessionsController
  layout 'devise'

  # GET /admin/login
  # def new
  #   super
  # end

  # POST /admin/login
  # def create
  #   super
  # end

  # DELETE /admin/logout
  # def destroy
  #   super
  # end

  protected

  def after_sign_in_path_for(resource)
    admin_dashboard_path
  end

  def after_sign_out_path_for(resource)
    new_admin_session_path
  end
end
