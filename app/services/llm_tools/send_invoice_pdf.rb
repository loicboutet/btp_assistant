# frozen_string_literal: true

# Tool: Re-send an invoice as PDF via WhatsApp
# Used when user wants to receive a specific invoice again
#
module LlmTools
  class SendInvoicePdf < BaseTool
    def execute(invoice_id:)
      return error("L'ID de la facture est obligatoire", field: "invoice_id") if invoice_id.blank?

      invoice = user.invoices.includes(:client, :items, :quote).find_by(id: invoice_id)
      
      unless invoice
        return error("Facture ##{invoice_id} non trouvée. Utilisez list_recent_invoices pour voir vos factures.")
      end

      # Generate and send PDF
      begin
        pdf_result = generate_and_send_invoice_pdf(invoice)
        
        unless pdf_result[:success]
          return error("Impossible d'envoyer la facture: #{pdf_result[:error]}")
        end
        
        # Update sent timestamp
        invoice.update(sent_via_whatsapp_at: Time.current)
        
        log_execution("invoice_pdf_sent", invoice_id: invoice.id, invoice_number: invoice.invoice_number)
        
        success(
          invoice_id: invoice.id,
          invoice_number: invoice.invoice_number,
          client_name: invoice.client.name,
          total: format_currency(invoice.total_amount),
          status: invoice.status,
          message: "Facture #{invoice.invoice_number} envoyée"
        )
      rescue UnipileClient::Error => e
        error("Impossible d'envoyer la facture: #{e.message}")
      end
    end
  end
end
