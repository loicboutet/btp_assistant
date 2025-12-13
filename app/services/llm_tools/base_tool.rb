# frozen_string_literal: true

# Base class for all LLM tools
# Provides common functionality for tool execution
#
# Usage:
#   class MyTool < LlmTools::BaseTool
#     def execute(query:)
#       # Implementation
#       success(data: { results: [...] })
#     end
#   end
#
module LlmTools
  class BaseTool
    attr_reader :user

    def initialize(user:, unipile_client: nil)
      @user = user
      @_unipile_client = unipile_client
    end

    # Lazy-load UnipileClient only when needed
    def unipile_client
      @_unipile_client ||= UnipileClient.new
    end

    # Main execution method - must be implemented by subclasses
    # @return [Hash] { success: true, data: {...} } or { success: false, error: "..." }
    def execute(**args)
      raise NotImplementedError, "#{self.class.name} must implement #execute"
    end

    protected

    # Return a successful result
    # @param data [Hash] The data to return
    # @return [Hash]
    def success(data = {})
      { success: true, data: data }
    end

    # Return an error result
    # @param message [String] Error message
    # @param field [String, nil] The field that caused the error (for validation errors)
    # @return [Hash]
    def error(message, field: nil)
      result = { success: false, error: message }
      result[:field] = field if field.present?
      result
    end

    # Check if user has an active subscription that allows document creation
    # @return [Boolean]
    def can_create_documents?
      user.can_create_documents?
    end

    # Check subscription and return error if not allowed
    # @return [Hash, nil] Error hash if not allowed, nil if allowed
    def check_subscription!
      return nil if can_create_documents?

      if user.pending?
        error("Vous devez avoir un abonnement actif pour créer des documents. " \
              "Utilisez la fonction send_payment_link pour obtenir un lien de paiement.")
      else
        error("Votre abonnement a expiré. " \
              "Utilisez la fonction send_payment_link pour réactiver votre compte.")
      end
    end

    # Format currency amount
    # @param amount [Numeric] Amount in euros
    # @return [String] Formatted amount (e.g., "1 234,56 €")
    def format_currency(amount)
      return "0,00 €" if amount.nil?
      
      # French number formatting
      formatted = "%.2f" % amount
      integer_part, decimal_part = formatted.split(".")
      integer_part = integer_part.reverse.gsub(/(\d{3})(?=\d)/, '\1 ').reverse
      "#{integer_part},#{decimal_part} €"
    end

    # Format date in French format
    # @param date [Date, DateTime] The date to format
    # @return [String] Formatted date (e.g., "15/01/2025")
    def format_date(date)
      return "" if date.nil?
      date.strftime("%d/%m/%Y")
    end

    # Get the chat ID for sending messages
    # @return [String, nil]
    def chat_id
      user.unipile_chat_id
    end

    # Send a message via WhatsApp
    # @param text [String] Message text
    # @return [Hash] API response
    def send_whatsapp_message(text)
      return error("No chat ID available") if chat_id.blank?
      
      unipile_client.send_message(chat_id: chat_id, text: text)
    end

    # Send a PDF via WhatsApp
    # @param file_path [String] Path to PDF file
    # @param filename [String] Display filename
    # @param text [String, nil] Accompanying message
    # @return [Hash] API response
    def send_pdf(file_path:, filename:, text: nil)
      return error("No chat ID available") if chat_id.blank?
      
      unipile_client.send_attachment(
        chat_id: chat_id,
        file_path: file_path,
        filename: filename,
        text: text
      )
    end

    # Send PDF from IO (in-memory)
    # @param io [IO, StringIO] PDF content
    # @param filename [String] Display filename
    # @param text [String, nil] Accompanying message
    # @return [Hash] API response
    def send_pdf_from_io(io:, filename:, text: nil)
      return error("No chat ID available") if chat_id.blank?
      
      unipile_client.send_attachment_from_io(
        chat_id: chat_id,
        io: io,
        filename: filename,
        content_type: "application/pdf",
        text: text
      )
    end

    # Generate and send a quote PDF via WhatsApp
    # @param quote [Quote] The quote to generate PDF for
    # @return [Hash] { success: true } or { success: false, error: "..." }
    def generate_and_send_quote_pdf(quote)
      begin
        pdf = PdfGenerators::QuotePdf.new(quote, user)
        
        send_pdf_from_io(
          io: pdf.to_io,
          filename: "#{quote.quote_number}.pdf",
          text: pdf_caption_for_quote(quote)
        )
        
        { success: true }
      rescue StandardError => e
        Rails.logger.error "Failed to generate/send quote PDF: #{e.message}"
        { success: false, error: e.message }
      end
    end

    # Generate and send an invoice PDF via WhatsApp
    # @param invoice [Invoice] The invoice to generate PDF for
    # @return [Hash] { success: true } or { success: false, error: "..." }
    def generate_and_send_invoice_pdf(invoice)
      begin
        pdf = PdfGenerators::InvoicePdf.new(invoice, user)
        
        send_pdf_from_io(
          io: pdf.to_io,
          filename: "#{invoice.invoice_number}.pdf",
          text: pdf_caption_for_invoice(invoice)
        )
        
        { success: true }
      rescue StandardError => e
        Rails.logger.error "Failed to generate/send invoice PDF: #{e.message}"
        { success: false, error: e.message }
      end
    end

    # Log tool execution to SystemLog
    # @param event [String] Event name
    # @param metadata [Hash] Additional metadata
    def log_execution(event, metadata = {})
      SystemLog.log_info(
        "tool_#{event}",
        description: "Tool #{self.class.name.demodulize} executed",
        user: user,
        metadata: metadata.merge(tool: self.class.name.demodulize)
      )
    end

    # Validate required parameters
    # @param params [Hash] Parameters to validate
    # @param required [Array<Symbol>] Required parameter names
    # @return [Hash, nil] Error hash if validation fails, nil if valid
    def validate_required(params, *required)
      missing = required.flatten.select { |key| params[key].blank? }
      
      return nil if missing.empty?
      
      error("Paramètres manquants: #{missing.join(', ')}", field: missing.first.to_s)
    end

    # Validate SIRET format (14 digits)
    # @param siret [String] SIRET to validate
    # @return [Hash, nil] Error hash if invalid, nil if valid
    def validate_siret(siret)
      return nil if siret.blank? # Optional field
      
      cleaned = siret.to_s.gsub(/\s/, '')
      return nil if cleaned.match?(/\A\d{14}\z/)
      
      error("Le SIRET doit contenir exactement 14 chiffres", field: "siret")
    end

    # Validate email format
    # @param email [String] Email to validate
    # @return [Hash, nil] Error hash if invalid, nil if valid
    def validate_email(email)
      return nil if email.blank? # Optional field
      return nil if email.match?(URI::MailTo::EMAIL_REGEXP)
      
      error("Format d'email invalide", field: "email")
    end

    private

    # Generate caption text for quote PDF
    # @param quote [Quote] The quote
    # @return [String] Caption text
    def pdf_caption_for_quote(quote)
      if user.french?
        "📄 Devis #{quote.quote_number}\n💰 Total: #{format_currency(quote.total_amount)} TTC"
      else
        "📄 Teklif #{quote.quote_number}\n💰 Toplam: #{format_currency(quote.total_amount)}"
      end
    end

    # Generate caption text for invoice PDF
    # @param invoice [Invoice] The invoice
    # @return [String] Caption text
    def pdf_caption_for_invoice(invoice)
      if user.french?
        "📄 Facture #{invoice.invoice_number}\n💰 Total: #{format_currency(invoice.total_amount)} TTC"
      else
        "📄 Fatura #{invoice.invoice_number}\n💰 Toplam: #{format_currency(invoice.total_amount)}"
      end
    end
  end
end
