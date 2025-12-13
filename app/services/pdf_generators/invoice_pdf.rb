# frozen_string_literal: true

# PDF Generator for invoices (Factures)
# Creates a professional French invoice document matching the HTML template
#
# Usage:
#   pdf = PdfGenerators::InvoicePdf.new(invoice, user)
#   pdf.to_pdf   # => Binary PDF string
#   pdf.to_io    # => StringIO for API uploads
#
module PdfGenerators
  class InvoicePdf < BasePdf
    def render
      render_header(
        document_type: "FACTURE",
        document_number: @record.invoice_number,
        date_label1: "Date",
        date1: @record.issue_date,
        date_label2: "Echeance",
        date2: @record.due_date
      )
      
      move_down 30
      render_parties
      
      # Show related quote if exists
      if @record.quote.present?
        move_down 10
        text "Reference devis : #{@record.quote.quote_number}", 
             size: 9, color: TEXT_GRAY, style: :italic
      end
      
      move_down 25
      render_items_table
      
      move_down 20
      render_totals
      
      render_payment_details
      
      render_notes if @record.notes.present?
      
      render_footer
    end

    private

    # Blue box with payment information
    def render_payment_details
      move_down 20
      
      fill_color BG_BLUE
      
      # Calculate box dimensions
      box_padding = 10
      box_height = 60
      
      # Draw background
      fill_rectangle [0, cursor], bounds.width, box_height
      fill_color "000000" # Reset

      bounding_box([box_padding, cursor - box_padding], width: bounds.width - (box_padding * 2)) do
        text "[PAIEMENT] Modalites de paiement", size: 10, style: :bold, color: TEXT_BLUE
        move_down 5
        
        payment_info = []
        payment_info << "Methode : Virement bancaire"
        payment_info << "Echeance : #{format_date(@record.due_date)}" if @record.due_date.present?
        
        text payment_info.join("\n"), size: 9, color: TEXT_BLUE, leading: 2
      end
      
      move_cursor_to(cursor - box_height + 20)
    end

    def render_notes
      render_notes_box(
        title: "Conditions de paiement et mentions legales",
        content: @record.notes,
        bg_color: BG_YELLOW,
        icon: "[!]"
      )
    end

    def render_footer
      move_down 25
      
      # Late payment penalty text (legal requirement in France)
      penalty_text = "En cas de retard de paiement, seront exigibles une indemnite calculee " \
                     "sur la base de 3 fois le taux d'interet legal, ainsi qu'une indemnite " \
                     "forfaitaire de 40 euros pour frais de recouvrement " \
                     "(articles L441-6 et D441-5 du Code de commerce)."
      
      text penalty_text, size: 7, color: TEXT_GRAY, align: :center, leading: 2
      
      move_down 15
      
      # Legal footer line
      footer_parts = []
      footer_parts << sanitize_text(@user.company_name) if @user.company_name.present?
      footer_parts << "SIRET : #{format_siret(@user.siret)}" if @user.siret.present?
      footer_parts << "TVA : #{@user.vat_number}" if @user.vat_number.present?
      
      text footer_parts.join(" - "), size: 8, color: TEXT_GRAY, align: :center
      
      # Status indicator for paid invoices
      if @record.paid?
        move_down 10
        text "[PAYEE] PAYEE LE #{format_date(@record.paid_at)}", 
             size: 10, style: :bold, color: PRIMARY_GREEN, align: :center
      end
    end
  end
end
