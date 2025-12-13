# frozen_string_literal: true

# Tool: List recent invoices for the user
# Helps users find their invoices and check payment status
#
module LlmTools
  class ListRecentInvoices < BaseTool
    MAX_LIMIT = 20
    DEFAULT_LIMIT = 5
    VALID_STATUSES = %w[draft sent paid overdue canceled].freeze

    def execute(limit: DEFAULT_LIMIT, status: nil)
      limit = [[limit.to_i, 1].max, MAX_LIMIT].min

      invoices = user.invoices.includes(:client).recent

      # Filter by status if provided
      if status.present? && VALID_STATUSES.include?(status)
        invoices = invoices.where(status: status)
      end

      invoices = invoices.limit(limit)

      if invoices.any?
        success(
          count: invoices.size,
          total_invoices: user.invoices.count,
          unpaid_count: user.invoices.unpaid.count,
          unpaid_total: format_currency(user.invoices.unpaid.sum(:total_amount)),
          invoices: invoices.map { |i| format_invoice(i) }
        )
      else
        message = status ? "Aucune facture avec le statut '#{status}'" : "Aucune facture trouvée"
        success(
          count: 0,
          total_invoices: user.invoices.count,
          unpaid_count: user.invoices.unpaid.count,
          unpaid_total: format_currency(user.invoices.unpaid.sum(:total_amount)),
          invoices: [],
          message: message
        )
      end
    end

    private

    def format_invoice(invoice)
      {
        id: invoice.id,
        invoice_number: invoice.invoice_number,
        client_name: invoice.client.name,
        client_id: invoice.client_id,
        issue_date: format_date(invoice.issue_date),
        due_date: format_date(invoice.due_date),
        status: invoice.status,
        status_label: status_label(invoice.status),
        subtotal: format_currency(invoice.subtotal_amount),
        vat_rate: "#{invoice.vat_rate}%",
        vat_amount: format_currency(invoice.vat_amount),
        total: format_currency(invoice.total_amount),
        items_count: invoice.items.count,
        paid_at: invoice.paid_at ? format_date(invoice.paid_at) : nil,
        days_overdue: invoice.days_overdue,
        from_quote: invoice.quote_id.present?,
        quote_number: invoice.quote&.quote_number
      }
    end

    def status_label(status)
      {
        "draft" => "Brouillon",
        "sent" => "Envoyée",
        "paid" => "Payée",
        "overdue" => "En retard",
        "canceled" => "Annulée"
      }[status] || status
    end
  end
end
