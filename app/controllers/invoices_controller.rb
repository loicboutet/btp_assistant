class InvoicesController < ApplicationController
  layout 'client'
  
  def index
    @invoices = [
      OpenStruct.new(id: 1, number: 'FACT-2025-001', client_name: 'Client A', amount: 6000, status: 'paid', due_date: 1.month.ago, created_at: 2.months.ago),
      OpenStruct.new(id: 2, number: 'FACT-2025-002', client_name: 'Client B', amount: 9000, status: 'pending', due_date: 15.days.from_now, created_at: 1.month.ago),
      OpenStruct.new(id: 3, number: 'FACT-2025-003', client_name: 'Client C', amount: 3840, status: 'overdue', due_date: 5.days.ago, created_at: 35.days.ago),
      OpenStruct.new(id: 4, number: 'FACT-2025-004', client_name: 'Client D', amount: 14400, status: 'pending', due_date: 20.days.from_now, created_at: 10.days.ago),
      OpenStruct.new(id: 5, number: 'FACT-2025-005', client_name: 'Client E', amount: 5400, status: 'paid', due_date: 2.months.ago, created_at: 3.months.ago)
    ]
  end

  def show
    @invoice = build_invoice_data
  end

  def destroy
    # TODO: When Invoice model is implemented, delete the actual record
    redirect_to invoices_path, notice: 'La facture a été supprimée avec succès.'
  end

  def pdf
    @invoice = build_invoice_data
    @company = build_company_data
    render layout: 'pdf'
  end

  def preview
    redirect_to invoice_path(params[:id]), notice: 'Preview not yet implemented.'
  end

  def send_whatsapp
    redirect_to invoice_path(params[:id]), notice: 'WhatsApp send not yet implemented.'
  end

  def status
    # TODO: When Invoice model is implemented, update the actual status
    redirect_to invoice_path(params[:id]), notice: 'Le statut de la facture a été mis à jour.'
  end

  private

  def build_invoice_data
    OpenStruct.new(
      id: params[:id],
      number: "FACT-2025-#{params[:id].to_s.rjust(3, '0')}",
      status: 'pending',
      created_at: 1.month.ago,
      due_date: 15.days.from_now,
      paid_at: nil,
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
      payment_method: 'Virement bancaire',
      bank_details: "IBAN : FR76 1234 5678 9012 3456 7890 123\nBIC : BNPAFRPPXXX",
      notes: "Paiement à 30 jours.\nPénalités de retard : 3 fois le taux d'intérêt légal.\nIndemnité forfaitaire pour frais de recouvrement : 40 euros."
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
