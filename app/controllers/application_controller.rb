class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout :determine_layout

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def determine_layout
    # Admin controllers use admin layout
    return 'admin' if self.class.name.start_with?('Admin::')
    # Devise controllers use devise layout
    return 'devise' if devise_controller?
    # All other controllers use client layout
    'client'
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, 
      :last_name, 
      :whatsapp_phone, 
      :company_name, 
      :siret, 
      :address, 
      :vat_number, 
      :preferred_language
    ])
    
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name, 
      :last_name, 
      :whatsapp_phone, 
      :company_name, 
      :siret, 
      :address, 
      :vat_number, 
      :preferred_language
    ])
  end
end
