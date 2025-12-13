# frozen_string_literal: true

# Tool executor - dispatches tool calls to the appropriate tool class
# Used by the conversation engine to execute tool calls from GPT-4
#
# Usage:
#   executor = LlmTools::Executor.new(user: user)
#   result = executor.execute(tool_name: "search_clients", arguments: { query: "Dupont" })
#   # => { success: true, data: [...] }
#
module LlmTools
  class Executor
    # Map of tool names to their implementing classes
    TOOLS = {
      "search_clients" => LlmTools::SearchClients,
      "create_client" => LlmTools::CreateClient,
      "create_quote" => LlmTools::CreateQuote,
      "create_invoice" => LlmTools::CreateInvoice,
      "list_recent_quotes" => LlmTools::ListRecentQuotes,
      "list_recent_invoices" => LlmTools::ListRecentInvoices,
      "send_quote_pdf" => LlmTools::SendQuotePdf,
      "send_invoice_pdf" => LlmTools::SendInvoicePdf,
      "mark_invoice_paid" => LlmTools::MarkInvoicePaid,
      "get_user_info" => LlmTools::GetUserInfo,
      "update_user_info" => LlmTools::UpdateUserInfo,
      "send_web_link" => LlmTools::SendWebLink,
      "send_payment_link" => LlmTools::SendPaymentLink
    }.freeze

    attr_reader :user, :unipile_client

    def initialize(user:, unipile_client: nil)
      @user = user
      @unipile_client = unipile_client
    end

    # Execute a tool by name
    # @param tool_name [String] The name of the tool to execute
    # @param arguments [Hash] Arguments to pass to the tool
    # @return [Hash] Tool result { success: true/false, data/error: ... }
    def execute(tool_name:, arguments:)
      tool_class = TOOLS[tool_name.to_s]
      
      unless tool_class
        Rails.logger.warn "[LlmTools::Executor] Unknown tool: #{tool_name}"
        return { success: false, error: "Unknown tool: #{tool_name}" }
      end

      begin
        tool = tool_class.new(user: user, unipile_client: unipile_client)
        
        # Symbolize keys and execute
        args = normalize_arguments(arguments)
        
        Rails.logger.info "[LlmTools::Executor] Executing #{tool_name} with args: #{args.inspect}"
        
        result = tool.execute(**args)
        
        Rails.logger.info "[LlmTools::Executor] #{tool_name} result: #{result[:success] ? 'success' : 'error'}"
        
        result
      rescue ArgumentError => e
        Rails.logger.error "[LlmTools::Executor] Argument error in #{tool_name}: #{e.message}"
        { success: false, error: "Invalid arguments: #{e.message}" }
      rescue StandardError => e
        Rails.logger.error "[LlmTools::Executor] Error executing #{tool_name}: #{e.message}"
        Rails.logger.error e.backtrace.first(5).join("\n")
        { success: false, error: "Tool execution failed: #{e.message}" }
      end
    end

    # Check if a tool exists
    # @param tool_name [String] Tool name
    # @return [Boolean]
    def self.tool_exists?(tool_name)
      TOOLS.key?(tool_name.to_s)
    end

    # Get all available tool names
    # @return [Array<String>]
    def self.available_tools
      TOOLS.keys
    end

    private

    def normalize_arguments(arguments)
      return {} if arguments.blank?
      
      # Handle both Hash and String (JSON) arguments
      args = arguments.is_a?(String) ? JSON.parse(arguments) : arguments
      
      # Deep symbolize keys
      deep_symbolize(args)
    rescue JSON::ParserError => e
      Rails.logger.warn "[LlmTools::Executor] Failed to parse arguments: #{e.message}"
      {}
    end

    def deep_symbolize(obj)
      case obj
      when Hash
        obj.transform_keys(&:to_sym).transform_values { |v| deep_symbolize(v) }
      when Array
        obj.map { |v| deep_symbolize(v) }
      else
        obj
      end
    end
  end
end
