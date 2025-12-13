# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout :determine_layout

  protected

  def determine_layout
    # Admin controllers use admin layout
    return 'admin' if self.class.name.start_with?('Admin::')
    # Devise controllers for admins use devise layout
    return 'devise' if devise_controller?
    # Artisan portal namespace uses client layout
    return 'client' if self.class.name.start_with?('Portal::')
    # Default to application layout
    'application'
  end

  # Helper to check if current request is in admin namespace
  def admin_area?
    self.class.name.start_with?('Admin::') || (devise_controller? && resource_name == :admin)
  end
end
