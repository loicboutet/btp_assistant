# frozen_string_literal: true

# Tool: Create a new invoice (facture) with line items
# Requires active subscription
# PDF is automatically generated and sent via WhatsApp after creation
#
module LlmTools
  class CreateInvoice < BaseTool
    DEFAULT_VAT_RATE = 20.0
    DEFAULT_DUE_DAYS = 30

    def execute(client_id:, items:, quote_id: nil, vat_rate: DEFAULT_VAT_RATE, notes: nil, due_days: DEFAULT_DUE_DAYS)
      # Check subscription
      subscription_error = check_subscription!
      return subscription_error if subscription_error

      # Validate client
      return error("L'ID du client est obligatoire", field: "client_id") if client_id.blank?
      
      client = user.clients.find_by(id: client_id)
      return error("Client ##{client_id} non trouvé. Utilisez search_clients pour trouver le bon client.") unless client

      # Validate quote if provided
      quote = nil
      if quote_id.present?
        quote = user.quotes.find_by(id: quote_id)
        return error("Devis ##{quote_id} non trouvé.") unless quote
        
        if quote.client_id != client_id
          return error("Le devis ##{quote_id} appartient à un autre client.")
        end
      end

      # Validate items
      items_validation = validate_items(items)
      return items_validation if items_validation.is_a?(Hash) && !items_validation[:success]

      # Validate VAT rate
      vat_rate = vat_rate.to_f
      unless vat_rate >= 0 && vat_rate <= 100
        return error("Le taux de TVA doit être entre 0 et 100", field: "vat_rate")
      end

      # Build the invoice
      invoice = user.invoices.build(
        client: client,
        quote: quote,
        issue_date: Date.current,
        due_date: Date.current + due_days.to_i.days,
        vat_rate: vat_rate,
        notes: notes&.strip,
        status: "draft"
      )

      # Add items
      items.each_with_index do |item, index|
        invoice.items.build(
          description: item[:description].to_s.strip,
          quantity: item[:quantity] || 1,
          unit: item[:unit] || "unité",
          unit_price: item[:unit_price].to_f,
          position: index
        )
      end

      # Calculate totals and save
      if invoice.save
        # Mark as sent since we're sending it immediately
        invoice.mark_as_sent!
        
        log_execution("invoice_created", 
          invoice_id: invoice.id, 
          invoice_number: invoice.invoice_number,
          client_name: client.name,
          total: invoice.total_amount,
          from_quote: quote&.quote_number
        )

        # Generate and send PDF via WhatsApp
        pdf_result = generate_and_send_invoice_pdf(invoice)
        
        success(
          invoice_id: invoice.id,
          invoice_number: invoice.invoice_number,
          client_name: client.name,
          issue_date: format_date(invoice.issue_date),
          due_date: format_date(invoice.due_date),
          items_count: invoice.items.count,
          subtotal: format_currency(invoice.subtotal_amount),
          vat_rate: "#{invoice.vat_rate}%",
          vat_amount: format_currency(invoice.vat_amount),
          total: format_currency(invoice.total_amount),
          from_quote: quote&.quote_number,
          pdf_sent: pdf_result[:success],
          message: "Facture #{invoice.invoice_number} créée pour #{client.name} - Total: #{format_currency(invoice.total_amount)}"
        )
      else
        error("Impossible de créer la facture: #{invoice.errors.full_messages.join(', ')}")
      end
    end

    private

    def validate_items(items)
      return error("Au moins une ligne est obligatoire", field: "items") if items.blank? || !items.is_a?(Array)
      
      items.each_with_index do |item, index|
        if item[:description].blank?
          return error("Description manquante pour la ligne #{index + 1}", field: "items[#{index}].description")
        end
        
        if item[:unit_price].blank? || item[:unit_price].to_f < 0
          return error("Prix unitaire invalide pour la ligne #{index + 1}", field: "items[#{index}].unit_price")
        end
        
        if item[:quantity].present? && item[:quantity].to_f < 0
          return error("Quantité invalide pour la ligne #{index + 1}", field: "items[#{index}].quantity")
        end
      end

      true
    end
  end
end
