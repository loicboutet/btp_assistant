# frozen_string_literal: true

# Base class for PDF document generation using Prawn
# Provides common styling, formatting, and layout methods for quotes and invoices
#
# Usage:
#   class MyPdf < PdfGenerators::BasePdf
#     def render
#       render_header
#       render_parties
#       render_items_table
#       render_totals
#     end
#   end
#
module PdfGenerators
  class BasePdf
    include Prawn::View
    include ActionView::Helpers::NumberHelper

    # Suppress Prawn's M17n warning
    Prawn::Fonts::AFM.hide_m17n_warning = true

    # Page settings
    PAGE_SIZE = "A4"
    PAGE_MARGIN = 40

    # Colors (from style guide)
    PRIMARY_GREEN = "1F9D55"
    DARK_GREEN = "128C7E"
    TEXT_DARK = "1F2937"
    TEXT_GRAY = "6B7280"
    BORDER_LIGHT = "E5E7EB"
    BG_LIGHT = "F0F2F5"
    BG_YELLOW = "FEF3C7"
    BG_BLUE = "DBEAFE"
    TEXT_BLUE = "1E3A8A"

    def initialize(record, user)
      @record = record
      @user = user
      @client = record.client
    end

    def document
      @document ||= Prawn::Document.new(
        page_size: PAGE_SIZE,
        margin: PAGE_MARGIN
      )
    end

    # Generate the PDF and return as binary string
    # @return [String] PDF binary data
    def to_pdf
      render
      document.render
    end

    # Generate the PDF and return as StringIO for API calls
    # @return [StringIO]
    def to_io
      StringIO.new(to_pdf)
    end

    protected

    # Must be implemented by subclasses
    def render
      raise NotImplementedError, "#{self.class.name} must implement #render"
    end

    # Render document header with company info and document details
    # @param document_type [String] "DEVIS" or "FACTURE"
    # @param document_number [String] The document number
    # @param date_label1 [String] First date label (e.g., "Date")
    # @param date1 [Date] First date
    # @param date_label2 [String] Second date label (e.g., "Validité" or "Échéance")
    # @param date2 [Date] Second date
    def render_header(document_type:, document_number:, date_label1:, date1:, date_label2:, date2:)
      # Company info on the left
      bounding_box([0, cursor], width: 250) do
        safe_text(@user.company_name || "Entreprise", size: 16, style: :bold, color: TEXT_DARK)
        move_down 5
        
        company_details = []
        company_details << @user.address if @user.address.present?
        company_details << "SIRET : #{format_siret(@user.siret)}" if @user.siret.present?
        company_details << "TVA : #{@user.vat_number}" if @user.vat_number.present?
        company_details << "Tel : #{@user.formatted_phone}" if @user.phone_number.present?
        
        safe_text(company_details.join("\n"), size: 9, color: TEXT_GRAY, leading: 3)
      end

      # Document info on the right
      bounding_box([bounds.width - 200, cursor + 70], width: 200) do
        text document_type, size: 28, style: :bold, color: PRIMARY_GREEN, align: :right
        move_down 5
        text document_number, size: 12, style: :bold, color: TEXT_DARK, align: :right
        move_down 3
        text "#{date_label1} : #{format_date(date1)}", size: 10, color: TEXT_GRAY, align: :right
        move_down 2
        text "#{date_label2} : #{format_date(date2)}", size: 10, color: TEXT_GRAY, align: :right
      end
    end

    # Render the two-column parties section (Entreprise and Client)
    def render_parties
      box_height = 80
      box_width = (bounds.width - 20) / 2

      # Save cursor position
      start_y = cursor

      # Left box: Entreprise
      bounding_box([0, start_y], width: box_width, height: box_height) do
        stroke_color BORDER_LIGHT
        stroke_bounds
        pad(8) do
          text "Entreprise", size: 8, color: TEXT_GRAY, style: :bold
          move_down 4
          safe_text(@user.company_name || "Non renseigne", size: 10, style: :bold, color: TEXT_DARK)
          move_down 2
          
          details = []
          details << @user.address if @user.address.present?
          details << "SIRET : #{format_siret(@user.siret)}" if @user.siret.present?
          details << @user.formatted_phone if @user.phone_number.present?
          
          safe_text(details.join("\n"), size: 9, color: TEXT_GRAY, leading: 2)
        end
      end

      # Right box: Client
      bounding_box([box_width + 20, start_y], width: box_width, height: box_height) do
        stroke_color BORDER_LIGHT
        stroke_bounds
        pad(8) do
          text "Client", size: 8, color: TEXT_GRAY, style: :bold
          move_down 4
          safe_text(@client.name, size: 10, style: :bold, color: TEXT_DARK)
          move_down 2
          
          client_details = []
          client_details << @client.address if @client.address.present?
          client_details << "SIRET : #{@client.formatted_siret}" if @client.siret.present?
          client_details << @client.contact_phone if @client.contact_phone.present?
          client_details << @client.contact_email if @client.contact_email.present?
          
          safe_text(client_details.join("\n"), size: 9, color: TEXT_GRAY, leading: 2)
        end
      end

      # Move cursor below the boxes
      move_cursor_to(start_y - box_height)
    end

    # Render the items table
    def render_items_table
      items = @record.items.order(:position)
      return if items.empty?

      table_data = [
        [
          { content: "Description", font_style: :bold },
          { content: "Quantite", font_style: :bold },
          { content: "Prix unitaire", font_style: :bold },
          { content: "Total HT", font_style: :bold }
        ]
      ]

      items.each do |item|
        qty = format_quantity(item.quantity)
        unit_display = item.unit.present? ? " #{sanitize_text(item.unit)}" : ""
        
        table_data << [
          sanitize_text(item.description),
          "#{qty}#{unit_display}",
          format_currency(item.unit_price),
          format_currency(item.total_price)
        ]
      end

      table(table_data, header: true, width: bounds.width) do |t|
        t.row(0).background_color = BG_LIGHT
        t.row(0).text_color = TEXT_DARK
        t.row(0).size = 9
        
        t.cells.borders = [:bottom]
        t.cells.border_color = BORDER_LIGHT
        t.cells.padding = [8, 6, 8, 6]
        t.cells.size = 9
        t.cells.text_color = TEXT_DARK

        # Column widths: Description 50%, Quantity 15%, Unit price 17.5%, Total 17.5%
        t.column(0).width = bounds.width * 0.50
        t.column(1).width = bounds.width * 0.15
        t.column(2).width = bounds.width * 0.175
        t.column(3).width = bounds.width * 0.175

        # Right-align numeric columns
        t.columns(1..3).align = :right
        
        # Header alignment
        t.row(0).columns(0).align = :left
        t.row(0).columns(1..3).align = :right

        # Bold totals in last column
        t.columns(3).font_style = :bold
      end
    end

    # Render the totals section (right-aligned)
    def render_totals
      totals_width = 200
      totals_x = bounds.width - totals_width

      bounding_box([totals_x, cursor], width: totals_width) do
        # Subtotal HT
        render_total_row("Total HT", format_currency(@record.subtotal_amount))
        
        # VAT
        vat_label = "TVA (#{@record.vat_rate.to_i}%)"
        render_total_row(vat_label, format_currency(@record.vat_amount))
        
        move_down 5
        stroke_color BORDER_LIGHT
        stroke_horizontal_rule
        move_down 5
        
        # Total TTC (emphasized)
        render_total_row("Total TTC", format_currency(@record.total_amount), bold: true, large: true)
      end
    end

    # Render notes section with colored background
    # @param title [String] Title of the notes section
    # @param content [String] Notes content
    # @param bg_color [String] Background color (hex)
    # @param icon [String] Text icon (ASCII safe)
    def render_notes_box(title:, content:, bg_color: BG_YELLOW, icon: "[!]")
      return if content.blank?
      
      move_down 20
      
      # Calculate box dimensions
      box_padding = 10
      min_height = 50
      
      fill_color bg_color
      fill_rectangle [0, cursor], bounds.width, min_height
      fill_color "000000" # Reset fill color
      
      bounding_box([box_padding, cursor - box_padding], width: bounds.width - (box_padding * 2)) do
        text "#{icon} #{sanitize_text(title)}", size: 10, style: :bold, color: TEXT_DARK
        move_down 5
        text sanitize_text(content), size: 9, color: TEXT_DARK, leading: 2
      end
      
      move_cursor_to(cursor - min_height + 30)
    end

    # Format currency in French format
    # @param amount [Numeric] Amount in euros
    # @return [String] Formatted amount (e.g., "1 234,56 EUR")
    def format_currency(amount)
      return "0,00 EUR" if amount.nil?
      
      formatted = "%.2f" % amount
      integer_part, decimal_part = formatted.split(".")
      integer_part = integer_part.reverse.gsub(/(\d{3})(?=\d)/, '\1 ').reverse
      "#{integer_part},#{decimal_part} EUR"
    end

    # Format date in French format
    # @param date [Date, DateTime] The date to format
    # @return [String] Formatted date (e.g., "15/01/2025")
    def format_date(date)
      return "" if date.nil?
      date.strftime("%d/%m/%Y")
    end

    # Format SIRET with spaces
    # @param siret [String] 14-digit SIRET
    # @return [String] Formatted SIRET (e.g., "123 456 789 01234")
    def format_siret(siret)
      return "" if siret.blank?
      siret.gsub(/(\d{3})(\d{3})(\d{3})(\d{5})/, '\1 \2 \3 \4')
    end

    # Format quantity (remove .0 for whole numbers)
    # @param qty [Numeric] Quantity
    # @return [String] Formatted quantity
    def format_quantity(qty)
      return "0" if qty.nil?
      qty == qty.to_i ? qty.to_i.to_s : "%.2f" % qty
    end

    # Sanitize text to be compatible with Prawn's default fonts
    # Replaces special characters with ASCII equivalents
    # @param text [String] Text to sanitize
    # @return [String] Sanitized text
    def sanitize_text(text)
      return "" if text.blank?
      
      result = text.to_s.dup
      
      # French accented characters
      result.gsub!(/[éèêëÉÈÊË]/, "e")
      result.gsub!(/[àâäÀÂÄ]/, "a")
      result.gsub!(/[ùûüÙÛÜ]/, "u")
      result.gsub!(/[îïÎÏ]/, "i")
      result.gsub!(/[ôöÔÖ]/, "o")
      result.gsub!(/[çÇ]/, "c")
      result.gsub!(/[œŒ]/, "oe")
      result.gsub!(/[æÆ]/, "ae")
      result.gsub!(/[ñÑ]/, "n")
      
      # Turkish special characters
      result.gsub!(/[İ]/, "I")
      result.gsub!(/[ı]/, "i")
      result.gsub!(/[Şş]/, "s")
      result.gsub!(/[Ğğ]/, "g")
      result.gsub!(/[Üü]/, "u")
      result.gsub!(/[Öö]/, "o")
      result.gsub!(/[Çç]/, "c")
      
      # Common symbols
      result.gsub!(/€/, "EUR")
      result.gsub!(/[—–]/, "-")
      result.gsub!(/['']/, "'")
      result.gsub!(/[""]/, '"')
      result.gsub!(/…/, "...")
      result.gsub!(/•/, "*")
      result.gsub!(/[™®©]/, "")
      
      # Final encoding
      result.encode("Windows-1252", invalid: :replace, undef: :replace, replace: "")
    end

    # Safe text rendering with sanitization
    # @param content [String] Text content
    # @param options [Hash] Prawn text options
    def safe_text(content, **options)
      text(sanitize_text(content), **options)
    end

    private

    # Helper to render a single total row
    def render_total_row(label, value, bold: false, large: false)
      font_style = bold ? :bold : :normal
      font_size = large ? 12 : 10
      
      move_down 3
      float do
        text label, size: font_size, style: font_style, color: TEXT_DARK
      end
      text value, size: font_size, style: font_style, color: TEXT_DARK, align: :right
    end
  end
end
