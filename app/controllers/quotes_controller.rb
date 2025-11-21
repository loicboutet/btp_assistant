class QuotesController < ApplicationController
  layout 'client'

  def index
    @quotes = [
      OpenStruct.new(id: 1, number: 'DEV-2025-001', client_name: 'Client A', amount: 5000, status: 'sent', created_at: 2.days.ago),
      OpenStruct.new(id: 2, number: 'DEV-2025-002', client_name: 'Client B', amount: 7500, status: 'accepted', created_at: 5.days.ago),
      OpenStruct.new(id: 3, number: 'DEV-2025-003', client_name: 'Client C', amount: 3200, status: 'draft', created_at: 7.days.ago),
      OpenStruct.new(id: 4, number: 'DEV-2025-004', client_name: 'Client D', amount: 12000, status: 'sent', created_at: 10.days.ago),
      OpenStruct.new(id: 5, number: 'DEV-2025-005', client_name: 'Client E', amount: 4500, status: 'rejected', created_at: 15.days.ago)
    ]
  end

  def show
    @quote = build_quote_data
  end

  def edit
    @quote = build_quote_data
    @quote.notes = ''
  end

  def update
    # TODO: When Quote model is implemented, update the actual record
    redirect_to quote_path(params[:id]), notice: 'Le devis a été mis à jour avec succès.'
  end

  def destroy
    # TODO: When Quote model is implemented, delete the actual record
    redirect_to quotes_path, notice: 'Le devis a été supprimé avec succès.'
  end

  def pdf
    @quote = build_quote_data
    @company = build_company_data
    render layout: 'pdf'
  end

  def preview
    redirect_to quote_path(params[:id]), notice: 'Preview not yet implemented.'
  end

  def send_whatsapp
    redirect_to quote_path(params[:id]), notice: 'WhatsApp send not yet implemented.'
  end

  private

  def build_quote_data
    OpenStruct.new(
      id: params[:id],
      number: "DEV-2025-#{params[:id].to_s.rjust(3, '0')}",
      status: 'sent',
      created_at: 2.days.ago,
      valid_until: 30.days.from_now,
      client: OpenStruct.new(
        name: 'Client Demo',
        email: 'client@example.com',
        phone: '+33 6 12 34 56 78',
        address: '123 Rue de la Construction, 75001 Paris',
        siret: '123 456 789 00012'
      ),
      items: [
        OpenStruct.new(description: 'Installation électrique complète', quantity: 1, unit_price: 3000, total: 3000),
        OpenStruct.new(description: 'Plomberie sanitaire', quantity: 1, unit_price: 2000, total: 2000)
      ],
      subtotal: 5000,
      tax_rate: 20,
      tax_amount: 1000,
      total: 6000,
      notes: "Conditions de paiement : 30% à la commande, 70% à la livraison.\nGarantie décennale incluse.\nDélai d'exécution : 2 semaines."
    )
  end

  def build_company_data
    OpenStruct.new(
      name: current_user&.company_name || 'Votre Entreprise BTP',
      siret: current_user&.siret || '987 654 321 00015',
      address: current_user&.address || '456 Avenue des Artisans, 75001 Paris',
      phone: current_user&.phone || '+33 6 12 34 56 78',
      email: current_user&.email || 'contact@votreentreprise.fr',
      tva: current_user&.tva_number || 'FR12345678901'
    )
  end
end
