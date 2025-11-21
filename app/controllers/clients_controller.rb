class ClientsController < ApplicationController
  layout 'client'
  
  def index
    @clients = [
      OpenStruct.new(
        id: 1, 
        name: 'Entreprise Martin', 
        email: 'contact@martin.fr', 
        phone: '+33 1 23 45 67 89',
        address: '12 Rue de la Paix, 75001 Paris',
        siret: '123 456 789 00012',
        quotes: OpenStruct.new(count: 12),
        invoices: OpenStruct.new(count: 8),
        total_revenue: 45000
      ),
      OpenStruct.new(
        id: 2, 
        name: 'Construction Dubois', 
        email: 'info@dubois.fr', 
        phone: '+33 1 98 76 54 32',
        address: '45 Avenue Victor Hugo, 69003 Lyon',
        siret: '234 567 890 00023',
        quotes: OpenStruct.new(count: 8),
        invoices: OpenStruct.new(count: 5),
        total_revenue: 32000
      ),
      OpenStruct.new(
        id: 3, 
        name: 'Rénovation Petit', 
        email: 'contact@petit.fr', 
        phone: '+33 1 11 22 33 44',
        address: '78 Boulevard des Artisans, 31000 Toulouse',
        siret: nil,
        quotes: OpenStruct.new(count: 15),
        invoices: OpenStruct.new(count: 10),
        total_revenue: 58000
      ),
      OpenStruct.new(
        id: 4, 
        name: 'BTP Solutions', 
        email: 'hello@btp-solutions.fr', 
        phone: '+33 1 55 66 77 88',
        address: '23 Rue du Commerce, 13001 Marseille',
        siret: '345 678 901 00034',
        quotes: OpenStruct.new(count: 20),
        invoices: OpenStruct.new(count: 15),
        total_revenue: 89000
      ),
      OpenStruct.new(
        id: 5, 
        name: 'Maçonnerie Bernard', 
        email: 'contact@bernard.fr', 
        phone: '+33 1 44 33 22 11',
        address: '56 Rue des Bâtisseurs, 33000 Bordeaux',
        siret: '456 789 012 00045',
        quotes: OpenStruct.new(count: 6),
        invoices: OpenStruct.new(count: 4),
        total_revenue: 21000
      )
    ]
  end

  def show
    @client = OpenStruct.new(
      id: params[:id],
      name: 'Entreprise Demo',
      email: 'contact@demo.fr',
      phone: '+33 1 23 45 67 89',
      address: '456 Avenue de la Construction, 69001 Lyon',
      siret: '987 654 321 00098',
      created_at: 6.months.ago,
      quotes: OpenStruct.new(count: 12),
      invoices: OpenStruct.new(count: 8),
      total_revenue: 45000,
      recent_quotes: [
        OpenStruct.new(id: 1, number: 'DEV-2025-001', amount: 5000, status: 'sent', created_at: 2.days.ago),
        OpenStruct.new(id: 2, number: 'DEV-2025-002', amount: 7500, status: 'accepted', created_at: 1.week.ago)
      ],
      recent_invoices: [
        OpenStruct.new(id: 1, number: 'FACT-2025-001', amount: 6000, status: 'paid', created_at: 2.weeks.ago),
        OpenStruct.new(id: 2, number: 'FACT-2025-002', amount: 9000, status: 'pending', created_at: 3.weeks.ago)
      ]
    )
  end

  def new
    @client = OpenStruct.new
  end

  def create
    redirect_to clients_path, notice: 'Client created successfully.'
  end

  def edit
    @client = OpenStruct.new(
      id: params[:id],
      name: 'Entreprise Demo',
      email: 'contact@demo.fr',
      phone: '+33 1 23 45 67 89',
      address: '456 Avenue de la Construction, 69001 Lyon',
      siret: '987 654 321 00098'
    )
  end

  def update
    redirect_to client_path(params[:id]), notice: 'Client updated successfully.'
  end

  def destroy
    redirect_to clients_path, notice: 'Client deleted successfully.'
  end
end
