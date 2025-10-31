class ClientsController < ApplicationController
  layout 'client'
  
  def index
    @clients = [
      OpenStruct.new(id: 1, name: 'Entreprise Martin', email: 'contact@martin.fr', phone: '+33 1 23 45 67 89', total_quotes: 12, total_invoices: 8, total_revenue: 45000),
      OpenStruct.new(id: 2, name: 'Construction Dubois', email: 'info@dubois.fr', phone: '+33 1 98 76 54 32', total_quotes: 8, total_invoices: 5, total_revenue: 32000),
      OpenStruct.new(id: 3, name: 'Rénovation Petit', email: 'contact@petit.fr', phone: '+33 1 11 22 33 44', total_quotes: 15, total_invoices: 10, total_revenue: 58000),
      OpenStruct.new(id: 4, name: 'BTP Solutions', email: 'hello@btp-solutions.fr', phone: '+33 1 55 66 77 88', total_quotes: 20, total_invoices: 15, total_revenue: 89000),
      OpenStruct.new(id: 5, name: 'Maçonnerie Bernard', email: 'contact@bernard.fr', phone: '+33 1 44 33 22 11', total_quotes: 6, total_invoices: 4, total_revenue: 21000)
    ]
  end

  def show
    @client = OpenStruct.new(
      id: params[:id],
      name: 'Entreprise Demo',
      email: 'contact@demo.fr',
      phone: '+33 1 23 45 67 89',
      address: '456 Avenue de la Construction',
      city: 'Lyon',
      postal_code: '69001',
      country: 'France',
      siret: '987 654 321 00098',
      created_at: 6.months.ago,
      total_quotes: 12,
      total_invoices: 8,
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
      address: '456 Avenue de la Construction',
      city: 'Lyon',
      postal_code: '69001',
      country: 'France',
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
