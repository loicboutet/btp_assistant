# frozen_string_literal: true

# Tool: Re-send a quote as PDF via WhatsApp
# Used when user wants to receive a specific quote again
#
module LlmTools
  class SendQuotePdf < BaseTool
    def execute(quote_id:)
      return error("L'ID du devis est obligatoire", field: "quote_id") if quote_id.blank?

      quote = user.quotes.includes(:client, :items).find_by(id: quote_id)
      
      unless quote
        return error("Devis ##{quote_id} non trouvé. Utilisez list_recent_quotes pour voir vos devis.")
      end

      # Generate and send PDF
      begin
        pdf_result = generate_and_send_quote_pdf(quote)
        
        unless pdf_result[:success]
          return error("Impossible d'envoyer le devis: #{pdf_result[:error]}")
        end
        
        # Update sent timestamp
        quote.update(sent_via_whatsapp_at: Time.current)
        
        log_execution("quote_pdf_sent", quote_id: quote.id, quote_number: quote.quote_number)
        
        success(
          quote_id: quote.id,
          quote_number: quote.quote_number,
          client_name: quote.client.name,
          total: format_currency(quote.total_amount),
          message: "Devis #{quote.quote_number} envoyé"
        )
      rescue UnipileClient::Error => e
        error("Impossible d'envoyer le devis: #{e.message}")
      end
    end
  end
end
