# frozen_string_literal: true

# Tool: Create a new quote (devis) with line items
# Requires active subscription
# PDF is automatically generated and sent via WhatsApp after creation
#
module LlmTools
  class CreateQuote < BaseTool
    DEFAULT_VAT_RATE = 20.0
    DEFAULT_VALIDITY_DAYS = 30

    def execute(client_id:, items:, vat_rate: DEFAULT_VAT_RATE, notes: nil, validity_days: DEFAULT_VALIDITY_DAYS)
      # Check subscription
      subscription_error = check_subscription!
      return subscription_error if subscription_error

      # Validate client
      return error("L'ID du client est obligatoire", field: "client_id") if client_id.blank?
      
      client = user.clients.find_by(id: client_id)
      return error("Client ##{client_id} non trouvé. Utilisez search_clients pour trouver le bon client.") unless client

      # Validate items
      items_validation = validate_items(items)
      return items_validation if items_validation.is_a?(Hash) && !items_validation[:success]

      # Validate VAT rate
      vat_rate = vat_rate.to_f
      unless vat_rate >= 0 && vat_rate <= 100
        return error("Le taux de TVA doit être entre 0 et 100", field: "vat_rate")
      end

      # Build the quote
      quote = user.quotes.build(
        client: client,
        issue_date: Date.current,
        validity_date: Date.current + validity_days.to_i.days,
        vat_rate: vat_rate,
        notes: notes&.strip,
        status: "draft"
      )

      # Add items
      items.each_with_index do |item, index|
        quote.items.build(
          description: item[:description].to_s.strip,
          quantity: item[:quantity] || 1,
          unit: item[:unit] || "unité",
          unit_price: item[:unit_price].to_f,
          position: index
        )
      end

      # Calculate totals and save
      if quote.save
        # Mark as sent since we're sending it immediately
        quote.mark_as_sent!
        
        log_execution("quote_created", 
          quote_id: quote.id, 
          quote_number: quote.quote_number,
          client_name: client.name,
          total: quote.total_amount
        )

        # Generate and send PDF via WhatsApp
        pdf_result = generate_and_send_quote_pdf(quote)
        
        success(
          quote_id: quote.id,
          quote_number: quote.quote_number,
          client_name: client.name,
          issue_date: format_date(quote.issue_date),
          validity_date: format_date(quote.validity_date),
          items_count: quote.items.count,
          subtotal: format_currency(quote.subtotal_amount),
          vat_rate: "#{quote.vat_rate}%",
          vat_amount: format_currency(quote.vat_amount),
          total: format_currency(quote.total_amount),
          pdf_sent: pdf_result[:success],
          message: "Devis #{quote.quote_number} créé pour #{client.name} - Total: #{format_currency(quote.total_amount)}"
        )
      else
        error("Impossible de créer le devis: #{quote.errors.full_messages.join(', ')}")
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
