# frozen_string_literal: true

# PDF Generator for quotes (Devis)
# Creates a professional French quote document matching the HTML template
#
# Usage:
#   pdf = PdfGenerators::QuotePdf.new(quote, user)
#   pdf.to_pdf   # => Binary PDF string
#   pdf.to_io    # => StringIO for API uploads
#
module PdfGenerators
  class QuotePdf < BasePdf
    def render
      render_header(
        document_type: "DEVIS",
        document_number: @record.quote_number,
        date_label1: "Date",
        date1: @record.issue_date,
        date_label2: "Validite",
        date2: @record.validity_date
      )
      
      move_down 30
      render_parties
      
      move_down 25
      render_items_table
      
      move_down 20
      render_totals
      
      render_notes if @record.notes.present?
      
      move_down 30
      render_signature_section
      
      render_footer
    end

    private

    def render_notes
      render_notes_box(
        title: "Conditions et remarques",
        content: @record.notes,
        bg_color: BG_YELLOW,
        icon: "[!]"
      )
    end

    # Two boxes for signatures: "Bon pour accord" and "L'entreprise"
    def render_signature_section
      box_height = 70
      box_width = (bounds.width - 30) / 2

      # Save cursor position
      start_y = cursor

      # Left box: Bon pour accord (Client signature)
      bounding_box([0, start_y], width: box_width, height: box_height) do
        stroke_color BORDER_LIGHT
        stroke_bounds
        pad(8) do
          text "Bon pour accord", size: 10, style: :bold, color: TEXT_DARK
          move_down 25
          text "Signature du client", size: 8, color: TEXT_GRAY
          move_down 3
          text "Date :", size: 8, color: TEXT_GRAY
        end
      end

      # Right box: L'entreprise
      bounding_box([box_width + 30, start_y], width: box_width, height: box_height) do
        stroke_color BORDER_LIGHT
        stroke_bounds
        pad(8) do
          text "L'entreprise", size: 10, style: :bold, color: TEXT_DARK
          move_down 8
          safe_text(@user.company_name || "", size: 9, color: TEXT_GRAY)
        end
      end

      # Move cursor below the boxes
      move_cursor_to(start_y - box_height)
    end

    def render_footer
      # Position at the bottom of the page
      move_down 20
      
      # Validity notice
      if @record.validity_date.present?
        text "Ce devis est valable jusqu'au #{format_date(@record.validity_date)}.", 
             size: 9, color: TEXT_GRAY, align: :center
      end
      
      text "En cas d'acceptation, merci de nous retourner ce document signe.",
           size: 9, color: TEXT_GRAY, align: :center
      
      move_down 10
      
      # Legal footer line
      footer_parts = []
      footer_parts << sanitize_text(@user.company_name) if @user.company_name.present?
      footer_parts << "SIRET : #{format_siret(@user.siret)}" if @user.siret.present?
      footer_parts << "TVA : #{@user.vat_number}" if @user.vat_number.present?
      
      text footer_parts.join(" - "), size: 8, color: TEXT_GRAY, align: :center
    end
  end
end
