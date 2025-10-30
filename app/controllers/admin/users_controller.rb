module Admin
  class UsersController < ApplicationController
    layout 'admin'
    
    def index
    end

    def show
    end

    def new
    end

    def create
      # Redirect back to the new form with success message
      redirect_to new_admin_user_path, notice: 'User created successfully.'
    end

    def edit
    end

    def update
    end

    def suspend
    end

    def activate
    end

    def reset_whatsapp
    end

    def logs
    end

    def stripe_portal
    end
  end
end
