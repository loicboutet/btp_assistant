# frozen_string_literal: true

# Tool: List recent quotes for the user
# Helps users find their quotes
#
module LlmTools
  class ListRecentQuotes < BaseTool
    MAX_LIMIT = 20
    DEFAULT_LIMIT = 5

    def execute(limit: DEFAULT_LIMIT, status: nil)
      limit = [[limit.to_i, 1].max, MAX_LIMIT].min

      quotes = user.quotes.includes(:client).recent

      # Filter by status if provided
      if status.present? && Quote::STATUSES.include?(status)
        quotes = quotes.where(status: status)
      end

      quotes = quotes.limit(limit)

      if quotes.any?
        success(
          count: quotes.size,
          total_quotes: user.quotes.count,
          quotes: quotes.map { |q| format_quote(q) }
        )
      else
        message = status ? "Aucun devis avec le statut '#{status}'" : "Aucun devis trouvé"
        success(
          count: 0,
          total_quotes: user.quotes.count,
          quotes: [],
          message: message
        )
      end
    end

    private

    def format_quote(quote)
      {
        id: quote.id,
        quote_number: quote.quote_number,
        client_name: quote.client.name,
        client_id: quote.client_id,
        issue_date: format_date(quote.issue_date),
        validity_date: format_date(quote.validity_date),
        status: quote.status,
        status_label: status_label(quote.status),
        subtotal: format_currency(quote.subtotal_amount),
        vat_rate: "#{quote.vat_rate}%",
        vat_amount: format_currency(quote.vat_amount),
        total: format_currency(quote.total_amount),
        items_count: quote.items.count,
        expired: quote.expired?
      }
    end

    def status_label(status)
      {
        "draft" => "Brouillon",
        "sent" => "Envoyé",
        "accepted" => "Accepté",
        "rejected" => "Refusé"
      }[status] || status
    end

    # Define valid statuses as a constant
    Quote::STATUSES = %w[draft sent accepted rejected].freeze unless defined?(Quote::STATUSES)
  end
end
