# frozen_string_literal: true

# Tool: Mark an invoice as paid
# Used when user confirms they received payment
#
module LlmTools
  class MarkInvoicePaid < BaseTool
    def execute(invoice_id:)
      return error("L'ID de la facture est obligatoire", field: "invoice_id") if invoice_id.blank?

      invoice = user.invoices.find_by(id: invoice_id)
      
      unless invoice
        return error("Facture ##{invoice_id} non trouvée. Vérifiez l'ID ou utilisez list_recent_invoices pour voir vos factures.")
      end

      # Check current status
      if invoice.paid?
        return success(
          already_paid: true,
          invoice_number: invoice.invoice_number,
          paid_at: format_date(invoice.paid_at),
          message: "Cette facture est déjà marquée comme payée"
        )
      end

      if invoice.canceled?
        return error("Impossible de marquer comme payée une facture annulée")
      end

      if invoice.draft?
        return error("Cette facture est en brouillon. Envoyez-la d'abord au client.")
      end

      # Mark as paid
      invoice.mark_as_paid!
      
      log_execution("invoice_marked_paid", invoice_id: invoice.id, invoice_number: invoice.invoice_number)

      success(
        invoice_id: invoice.id,
        invoice_number: invoice.invoice_number,
        client_name: invoice.client.name,
        total: format_currency(invoice.total_amount),
        paid_at: format_date(invoice.paid_at),
        message: "Facture #{invoice.invoice_number} marquée comme payée ✅"
      )
    end
  end
end
