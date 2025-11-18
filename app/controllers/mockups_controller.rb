class MockupsController < ApplicationController
  # Set the layout based on the action
  layout :resolve_layout
  
  def index
    # Main index page that lists all mockup journeys
  end
  
  # User journey pages (Bot-First Architecture)
  def user_dashboard
    # Simple dashboard with 4 big cards
  end
  
  def user_quotes_list
    # Quotes list with search and filters
  end
  
  def user_profile
    # User profile with magic link management
  end
  
  def signup_success
    # Success page after payment with WhatsApp button
  end
  
  def user_settings
    # User settings mockup (legacy - may not be needed)
  end
  
  # Admin journey pages
  def admin_dashboard
    # Admin dashboard mockup
  end
  
  def admin_users
    # Admin users management mockup
  end
  
  def admin_analytics
    # Admin analytics mockup
  end
  
  private
  
  # Determine which layout to use based on the action name
  def resolve_layout
    if action_name == 'index'
      'application'
    elsif action_name.start_with?('user_') || action_name == 'signup_success'
      'mockup_user'
    elsif action_name.start_with?('admin_')
      'mockup_admin'
    else
      'application'
    end
  end
end
