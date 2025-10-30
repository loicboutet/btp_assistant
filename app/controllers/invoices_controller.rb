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
    @invoice = OpenStruct.new(
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
        address: '123 Rue de la Construction, 75001 Paris'
      ),
      items: [
        OpenStruct.new(description: 'Installation électrique', quantity: 1, unit_price: 3000, total: 3000),
        OpenStruct.new(description: 'Plomberie sanitaire', quantity: 1, unit_price: 2000, total: 2000)
      ],
      subtotal: 5000,
      tax_rate: 20,
      tax_amount: 1000,
      total: 6000,
      payments: [
        OpenStruct.new(amount: 2000, date: 5.days.ago, method: 'bank_transfer')
      ],
      balance_due: 4000
    )
  end

  def pdf
    redirect_to invoice_path(params[:id]), notice: 'PDF generation not yet implemented.'
  end

  def preview
    redirect_to invoice_path(params[:id]), notice: 'Preview not yet implemented.'
  end

  def send_whatsapp
    redirect_to invoice_path(params[:id]), notice: 'WhatsApp send not yet implemented.'
  end

  def status
    redirect_to invoice_path(params[:id]), notice: 'Status update not yet implemented.'
  end
end
