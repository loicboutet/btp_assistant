# frozen_string_literal: true

# OpenAI function calling tool definitions
# Each tool is defined with a JSON schema that GPT-4 uses to understand
# when and how to call the function
#
# Usage:
#   tools = LlmTools::ToolDefinitions::TOOLS
#   response = openai_client.chat_with_tools(messages: messages, tools: tools)
#
module LlmTools
  module ToolDefinitions
    # All available tools for the BTP Assistant
    TOOLS = [
      # ==========================================
      # Client Management Tools
      # ==========================================
      {
        type: "function",
        function: {
          name: "search_clients",
          description: "Search for existing clients by name. Use this before creating a quote or invoice to find the client, or to check if a client already exists before creating a new one.",
          parameters: {
            type: "object",
            properties: {
              query: {
                type: "string",
                description: "Client name or part of the name to search for"
              }
            },
            required: ["query"]
          }
        }
      },
      {
        type: "function",
        function: {
          name: "create_client",
          description: "Create a new client. Use this when the user wants to create a quote or invoice for a client that doesn't exist yet. Collect at least the client name before calling.",
          parameters: {
            type: "object",
            properties: {
              name: {
                type: "string",
                description: "Full name of the client (person or company)"
              },
              address: {
                type: "string",
                description: "Client's full address (street, city, postal code)"
              },
              siret: {
                type: "string",
                description: "SIRET number (14 digits) if the client is a professional. Optional for individuals."
              },
              contact_phone: {
                type: "string",
                description: "Client's phone number"
              },
              contact_email: {
                type: "string",
                description: "Client's email address"
              }
            },
            required: ["name"]
          }
        }
      },

      # ==========================================
      # Quote Management Tools
      # ==========================================
      {
        type: "function",
        function: {
          name: "create_quote",
          description: "Create a new quote (devis) with line items. The quote is automatically sent as a PDF via WhatsApp after creation. You must have a valid client_id (use search_clients or create_client first).",
          parameters: {
            type: "object",
            properties: {
              client_id: {
                type: "integer",
                description: "The ID of the client for this quote (from search_clients or create_client)"
              },
              items: {
                type: "array",
                description: "List of line items for the quote",
                items: {
                  type: "object",
                  properties: {
                    description: {
                      type: "string",
                      description: "Description of the work or product"
                    },
                    quantity: {
                      type: "number",
                      description: "Quantity (default: 1)"
                    },
                    unit: {
                      type: "string",
                      description: "Unit of measurement (e.g., 'm²', 'heure', 'unité', 'forfait')"
                    },
                    unit_price: {
                      type: "number",
                      description: "Price per unit in euros (HT - excluding VAT)"
                    }
                  },
                  required: ["description", "unit_price"]
                }
              },
              vat_rate: {
                type: "number",
                description: "VAT rate as percentage (default: 20). Common values: 20, 10, 5.5"
              },
              notes: {
                type: "string",
                description: "Additional notes or comments for the quote"
              },
              validity_days: {
                type: "integer",
                description: "Number of days the quote is valid (default: 30)"
              }
            },
            required: ["client_id", "items"]
          }
        }
      },
      {
        type: "function",
        function: {
          name: "list_recent_quotes",
          description: "List the user's recent quotes. Useful to help the user find a quote they're looking for.",
          parameters: {
            type: "object",
            properties: {
              limit: {
                type: "integer",
                description: "Maximum number of quotes to return (default: 5, max: 20)"
              },
              status: {
                type: "string",
                enum: ["draft", "sent", "accepted", "rejected"],
                description: "Filter by quote status (optional)"
              }
            },
            required: []
          }
        }
      },
      {
        type: "function",
        function: {
          name: "send_quote_pdf",
          description: "Re-send a quote as PDF via WhatsApp. Use this when the user asks to receive a specific quote again.",
          parameters: {
            type: "object",
            properties: {
              quote_id: {
                type: "integer",
                description: "The ID of the quote to send"
              }
            },
            required: ["quote_id"]
          }
        }
      },

      # ==========================================
      # Invoice Management Tools
      # ==========================================
      {
        type: "function",
        function: {
          name: "create_invoice",
          description: "Create a new invoice (facture) with line items. The invoice is automatically sent as a PDF via WhatsApp after creation. You must have a valid client_id. Can optionally be linked to an existing quote.",
          parameters: {
            type: "object",
            properties: {
              client_id: {
                type: "integer",
                description: "The ID of the client for this invoice (from search_clients or create_client)"
              },
              items: {
                type: "array",
                description: "List of line items for the invoice",
                items: {
                  type: "object",
                  properties: {
                    description: {
                      type: "string",
                      description: "Description of the work or product"
                    },
                    quantity: {
                      type: "number",
                      description: "Quantity (default: 1)"
                    },
                    unit: {
                      type: "string",
                      description: "Unit of measurement (e.g., 'm²', 'heure', 'unité', 'forfait')"
                    },
                    unit_price: {
                      type: "number",
                      description: "Price per unit in euros (HT - excluding VAT)"
                    }
                  },
                  required: ["description", "unit_price"]
                }
              },
              quote_id: {
                type: "integer",
                description: "ID of the quote this invoice is based on (optional)"
              },
              vat_rate: {
                type: "number",
                description: "VAT rate as percentage (default: 20). Common values: 20, 10, 5.5"
              },
              notes: {
                type: "string",
                description: "Additional notes or comments for the invoice"
              },
              due_days: {
                type: "integer",
                description: "Number of days until payment is due (default: 30)"
              }
            },
            required: ["client_id", "items"]
          }
        }
      },
      {
        type: "function",
        function: {
          name: "list_recent_invoices",
          description: "List the user's recent invoices. Useful to help the user find an invoice or check payment status.",
          parameters: {
            type: "object",
            properties: {
              limit: {
                type: "integer",
                description: "Maximum number of invoices to return (default: 5, max: 20)"
              },
              status: {
                type: "string",
                enum: ["draft", "sent", "paid", "overdue", "canceled"],
                description: "Filter by invoice status (optional)"
              }
            },
            required: []
          }
        }
      },
      {
        type: "function",
        function: {
          name: "send_invoice_pdf",
          description: "Re-send an invoice as PDF via WhatsApp. Use this when the user asks to receive a specific invoice again.",
          parameters: {
            type: "object",
            properties: {
              invoice_id: {
                type: "integer",
                description: "The ID of the invoice to send"
              }
            },
            required: ["invoice_id"]
          }
        }
      },
      {
        type: "function",
        function: {
          name: "mark_invoice_paid",
          description: "Mark an invoice as paid. Use this when the user confirms they received payment for an invoice.",
          parameters: {
            type: "object",
            properties: {
              invoice_id: {
                type: "integer",
                description: "The ID of the invoice to mark as paid"
              }
            },
            required: ["invoice_id"]
          }
        }
      },

      # ==========================================
      # User Information Tools
      # ==========================================
      {
        type: "function",
        function: {
          name: "get_user_info",
          description: "Get the current user's company information. Use this to check what information is already filled in or to answer questions about the user's account.",
          parameters: {
            type: "object",
            properties: {},
            required: []
          }
        }
      },
      {
        type: "function",
        function: {
          name: "update_user_info",
          description: "Update the user's company information. Use this during onboarding or when the user wants to change their business details. All parameters are optional - only include fields to update.",
          parameters: {
            type: "object",
            properties: {
              company_name: {
                type: "string",
                description: "Company or business name"
              },
              siret: {
                type: "string",
                description: "SIRET number (14 digits)"
              },
              address: {
                type: "string",
                description: "Business address (street, city, postal code)"
              },
              vat_number: {
                type: "string",
                description: "VAT/TVA number (e.g., FR12345678901)"
              },
              preferred_language: {
                type: "string",
                enum: ["fr", "tr"],
                description: "Preferred language for communication (fr=French, tr=Turkish)"
              }
            },
            required: []
          }
        }
      },

      # ==========================================
      # Access & Payment Tools
      # ==========================================
      {
        type: "function",
        function: {
          name: "send_web_link",
          description: "Send a secure link for web access. Use this when the user asks to view their documents in a browser, access their dashboard, or needs a web interface.",
          parameters: {
            type: "object",
            properties: {},
            required: []
          }
        }
      },
      {
        type: "function",
        function: {
          name: "send_payment_link",
          description: "Send a Stripe payment link for subscription. Use this for new users who need to subscribe, or for users with canceled/pending subscriptions who want to reactivate.",
          parameters: {
            type: "object",
            properties: {},
            required: []
          }
        }
      }
    ].freeze

    # Get a tool definition by name
    def self.find(name)
      TOOLS.find { |t| t.dig(:function, :name) == name.to_s }
    end

    # Get all tool names
    def self.names
      TOOLS.map { |t| t.dig(:function, :name) }
    end

    # Get tools filtered by names
    def self.subset(*names)
      names = names.flatten.map(&:to_s)
      TOOLS.select { |t| names.include?(t.dig(:function, :name)) }
    end
  end
end
