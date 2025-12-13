# frozen_string_literal: true

# Tool: Search for existing clients by name
# Used to find clients before creating quotes/invoices
#
module LlmTools
  class SearchClients < BaseTool
    MAX_RESULTS = 10

    def execute(query:)
      return error("Query is required") if query.blank?

      clients = user.clients
                    .where("name LIKE ?", "%#{sanitize_query(query)}%")
                    .order(:name)
                    .limit(MAX_RESULTS)

      if clients.any?
        success(
          count: clients.size,
          clients: clients.map { |c| format_client(c) }
        )
      else
        success(
          count: 0,
          clients: [],
          message: "Aucun client trouvé pour '#{query}'"
        )
      end
    end

    private

    def sanitize_query(query)
      # Remove SQL wildcards from user input to prevent injection
      query.to_s.gsub(/[%_]/, '')
    end

    def format_client(client)
      {
        id: client.id,
        name: client.name,
        address: client.address,
        siret: client.siret,
        contact_phone: client.contact_phone,
        contact_email: client.contact_email,
        is_professional: client.professional?,
        total_quotes: client.quotes.count,
        total_invoices: client.invoices.count
      }
    end
  end
end
