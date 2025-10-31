class DashboardController < ApplicationController
  layout 'client'

  def index
    # Dummy data for mockup demonstration
    # TODO: Replace with actual data when models and authentication are ready
    @quotes_count = 12
    @invoices_count = 8
    @clients_count = 5
    @total_revenue = 15_250.00
    @whatsapp_connected = false
    
    # Mock user data
    @mock_user_email = "artisan@example.com"
    @mock_user_name = "Artisan"
    
    # Recent activity (dummy data)
    @recent_activities = [
      { type: 'quote', client: 'Entreprise Dubois', amount: 5100.00, date: 2.days.ago },
      { type: 'invoice', client: 'Maçonnerie Martin', amount: 3200.00, date: 3.days.ago },
      { type: 'client', name: 'Construction Yilmaz', date: 5.days.ago }
    ]
  end
end
