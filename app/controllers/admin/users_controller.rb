module Admin
  class UsersController < ApplicationController
    layout 'admin'
    
    def index
      @users = []
    end

    def show
      @user = OpenStruct.new(
        id: params[:id],
        email: 'jean.dupont@example.fr',
        first_name: 'Jean',
        last_name: 'Dupont',
        phone: '+33 6 12 34 56 78',
        company_name: 'Dupont Maçonnerie',
        siret: '123 456 789 00012',
        address: '15 Rue de la Maçonnerie, 75010 Paris'
      )
    end

    def new
      @user = OpenStruct.new
    end

    def create
      redirect_to admin_users_path, notice: 'Utilisateur créé avec succès.'
    end

    def edit
      @user = OpenStruct.new(
        id: params[:id],
        email: 'jean.dupont@example.fr',
        first_name: 'Jean',
        last_name: 'Dupont'
      )
    end

    def update
      redirect_to admin_user_path(params[:id]), notice: 'Utilisateur mis à jour.'
    end

    def suspend
      redirect_to admin_user_path(params[:id]), notice: 'Utilisateur suspendu.'
    end

    def activate
      redirect_to admin_user_path(params[:id]), notice: 'Utilisateur activé.'
    end

    def reset_whatsapp
      redirect_to admin_user_path(params[:id]), notice: 'WhatsApp réinitialisé.'
    end

    def logs
      @user = OpenStruct.new(id: params[:id], first_name: 'Jean', last_name: 'Dupont')
    end

    def stripe_portal
      @user = OpenStruct.new(id: params[:id], first_name: 'Jean', last_name: 'Dupont')
    end

    def create_stripe_portal
      redirect_to admin_user_path(params[:id]), notice: 'Session Stripe créée.'
    end

    # Clients mockup actions
    def clients
    end

    def show_client
    end

    def edit_client
    end

    # Quotes mockup actions
    def quotes
    end

    def show_quote
    end

    # Invoices mockup actions
    def invoices
    end

    def show_invoice
    end
  end
end
