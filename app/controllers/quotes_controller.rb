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
    @quote = OpenStruct.new(
      id: params[:id],
      number: "DEV-2025-#{params[:id].to_s.rjust(3, '0')}",
      status: 'sent',
      created_at: 2.days.ago,
      valid_until: 30.days.from_now,
      client: OpenStruct.new(
        name: 'Client Demo',
        email: 'client@example.com',
        phone: '+33 6 12 34 56 78',
        address: '123 Rue de la Construction, 75001 Paris'
      ),
      items: [
        OpenStruct.new(description: 'Installation électrique', quantity: 1, unit_price: 3000, total: 3000),
        OpenStruct.new(description: 'Plomberie sanitaire', quantity: 1, unit_price: 2000, total: 2000)
      ],
      subtotal: 5000,
      tax_rate: 20,
      tax_amount: 1000,
      total: 6000
    )
  end

  def pdf
    redirect_to quote_path(params[:id]), notice: 'PDF generation not yet implemented.'
  end

  def preview
    redirect_to quote_path(params[:id]), notice: 'Preview not yet implemented.'
  end

  def send_whatsapp
    redirect_to quote_path(params[:id]), notice: 'WhatsApp send not yet implemented.'
  end
end
