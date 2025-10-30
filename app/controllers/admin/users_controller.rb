module Admin
  class UsersController < ApplicationController
    layout 'admin'
    
    def index
      @users = [
        OpenStruct.new(id: 1, email: 'user1@example.com', first_name: 'Jean', last_name: 'Dupont', company_name: 'BTP Solutions', subscription_status: 'active', created_at: 3.months.ago),
        OpenStruct.new(id: 2, email: 'user2@example.com', first_name: 'Marie', last_name: 'Martin', company_name: 'Rénovation Pro', subscription_status: 'active', created_at: 2.months.ago),
        OpenStruct.new(id: 3, email: 'user3@example.com', first_name: 'Pierre', last_name: 'Dubois', company_name: 'Construction Plus', subscription_status: 'suspended', created_at: 4.months.ago),
        OpenStruct.new(id: 4, email: 'user4@example.com', first_name: 'Sophie', last_name: 'Bernard', company_name: 'Travaux Express', subscription_status: 'trial', created_at: 1.week.ago),
        OpenStruct.new(id: 5, email: 'user5@example.com', first_name: 'Luc', last_name: 'Petit', company_name: 'Maçonnerie Luc', subscription_status: 'cancelled', created_at: 6.months.ago)
      ]
    end

    def show
      @user = OpenStruct.new(
        id: params[:id],
        email: 'demo@example.com',
        first_name: 'Jean',
        last_name: 'Dupont',
        phone: '+33 6 12 34 56 78',
        company_name: 'BTP Solutions SARL',
        siret: '123 456 789 00012',
        address: '123 Rue de la Construction',
        city: 'Paris',
        postal_code: '75001',
        subscription_status: 'active',
        subscription_plan: 'Professional',
        subscription_started_at: 3.months.ago,
        total_quotes: 24,
        total_invoices: 18,
        total_revenue: 87000,
        whatsapp_connected: true,
        created_at: 3.months.ago
      )
    end

    def new
      @user = OpenStruct.new
    end

    def create
      redirect_to admin_users_path, notice: 'User created successfully.'
    end

    def edit
      @user = OpenStruct.new(
        id: params[:id],
        email: 'demo@example.com',
        first_name: 'Jean',
        last_name: 'Dupont',
        phone: '+33 6 12 34 56 78',
        company_name: 'BTP Solutions SARL',
        siret: '123 456 789 00012',
        address: '123 Rue de la Construction',
        city: 'Paris',
        postal_code: '75001'
      )
    end

    def update
      redirect_to admin_user_path(params[:id]), notice: 'User updated successfully.'
    end

    def suspend
      redirect_to admin_user_path(params[:id]), notice: 'User suspended successfully.'
    end

    def activate
      redirect_to admin_user_path(params[:id]), notice: 'User activated successfully.'
    end

    def reset_whatsapp
      redirect_to admin_user_path(params[:id]), notice: 'WhatsApp connection reset successfully.'
    end

    def logs
      @user = OpenStruct.new(id: params[:id], email: 'demo@example.com', first_name: 'Jean', last_name: 'Dupont')
      @logs = [
        OpenStruct.new(id: 1, action: 'login', ip_address: '192.168.1.1', created_at: 1.hour.ago),
        OpenStruct.new(id: 2, action: 'quote_created', ip_address: '192.168.1.1', created_at: 2.hours.ago),
        OpenStruct.new(id: 3, action: 'invoice_sent', ip_address: '192.168.1.1', created_at: 5.hours.ago)
      ]
    end

    def stripe_portal
      redirect_to admin_user_path(params[:id]), notice: 'Stripe portal session created.'
    end
  end
end
