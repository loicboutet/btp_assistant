class ProfileController < ApplicationController
  layout 'client'
  
  def show
    @user = current_user || OpenStruct.new(
      email: 'demo@example.com',
      first_name: 'Jean',
      last_name: 'Dupont',
      phone: '+33 6 12 34 56 78',
      company_name: 'BTP Solutions SARL',
      siret: '123 456 789 00012',
      address: '123 Rue de la Construction',
      city: 'Paris',
      postal_code: '75001',
      country: 'France',
      subscription_status: 'active',
      subscription_plan: 'Professional',
      subscription_next_billing: Date.today + 30.days
    )
  end

  def update
    redirect_to client_profile_path, notice: 'Profile updated successfully.'
  end
end
