# frozen_string_literal: true

module Portal
  class InvoicesController < Portal::BaseController
    before_action :set_invoice, only: [:show, :pdf, :send_whatsapp]

    def index
      @invoices = current_user.invoices
                              .includes(:client)
                              .order(created_at: :desc)

      # Filtering
      @invoices = @invoices.where(status: params[:status]) if params[:status].present?
      @invoices = @invoices.where(client_id: params[:client_id]) if params[:client_id].present?

      # Search by invoice_number or client name
      if params[:search].present?
        search = "%#{params[:search]}%"
        @invoices = @invoices.joins(:client).where(
          "invoices.invoice_number LIKE ? OR clients.name LIKE ?", search, search
        )
      end

      @invoices = paginate(@invoices, per_page: 20)

      # For filters dropdown
      @clients = current_user.clients.order(:name)
    end

    def show
      # @invoice is set by before_action
    end

    def pdf
      pdf = PdfGenerators::InvoicePdf.new(@invoice, current_user)

      send_data pdf.to_pdf,
                filename: "#{@invoice.invoice_number}.pdf",
                type: 'application/pdf',
                disposition: 'attachment'
    end

    def send_whatsapp
      # Resend invoice via WhatsApp using Unipile
      if current_user.unipile_chat_id.present?
        pdf = PdfGenerators::InvoicePdf.new(@invoice, current_user)

        begin
          UnipileClient.new.send_attachment_from_io(
            chat_id: current_user.unipile_chat_id,
            io: pdf.to_io,
            filename: "#{@invoice.invoice_number}.pdf",
            content_type: 'application/pdf',
            text: t('client.invoices.whatsapp_message', number: @invoice.invoice_number)
          )

          @invoice.update!(sent_via_whatsapp_at: Time.current)
          redirect_to client_invoice_path(@invoice), notice: t('client.invoices.sent_whatsapp')
        rescue UnipileClient::ApiError
          redirect_to client_invoice_path(@invoice), alert: t('client.invoices.whatsapp_error')
        end
      else
        redirect_to client_invoice_path(@invoice), alert: t('client.invoices.no_whatsapp')
      end
    end

    private

    def set_invoice
      @invoice = current_user.invoices.includes(:client, :items).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to client_invoices_path, alert: t('client.invoices.not_found')
    end
  end
end
