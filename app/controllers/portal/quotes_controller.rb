# frozen_string_literal: true

module Portal
  class QuotesController < Portal::BaseController
    before_action :set_quote, only: [:show, :pdf, :send_whatsapp]

    def index
      @quotes = current_user.quotes
                            .includes(:client)
                            .order(created_at: :desc)

      # Filtering
      @quotes = @quotes.where(status: params[:status]) if params[:status].present?
      @quotes = @quotes.where(client_id: params[:client_id]) if params[:client_id].present?

      # Search by quote_number or client name
      if params[:search].present?
        search = "%#{params[:search]}%"
        @quotes = @quotes.joins(:client).where(
          "quotes.quote_number LIKE ? OR clients.name LIKE ?", search, search
        )
      end

      @quotes = paginate(@quotes, per_page: 20)

      # For filters dropdown
      @clients = current_user.clients.order(:name)
    end

    def show
      # @quote is set by before_action
    end

    def pdf
      pdf = PdfGenerators::QuotePdf.new(@quote, current_user)

      send_data pdf.to_pdf,
                filename: "#{@quote.quote_number}.pdf",
                type: 'application/pdf',
                disposition: 'attachment'
    end

    def send_whatsapp
      # Resend quote via WhatsApp using Unipile
      if current_user.unipile_chat_id.present?
        pdf = PdfGenerators::QuotePdf.new(@quote, current_user)

        begin
          UnipileClient.new.send_attachment_from_io(
            chat_id: current_user.unipile_chat_id,
            io: pdf.to_io,
            filename: "#{@quote.quote_number}.pdf",
            content_type: 'application/pdf',
            text: t('client.quotes.whatsapp_message', number: @quote.quote_number)
          )

          @quote.update!(sent_via_whatsapp_at: Time.current)
          redirect_to client_quote_path(@quote), notice: t('client.quotes.sent_whatsapp')
        rescue UnipileClient::ApiError
          redirect_to client_quote_path(@quote), alert: t('client.quotes.whatsapp_error')
        end
      else
        redirect_to client_quote_path(@quote), alert: t('client.quotes.no_whatsapp')
      end
    end

    private

    def set_quote
      @quote = current_user.quotes.includes(:client, :items).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to client_quotes_path, alert: t('client.quotes.not_found')
    end
  end
end
