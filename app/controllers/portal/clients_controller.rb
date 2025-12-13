# frozen_string_literal: true

module Portal
  class ClientsController < Portal::BaseController
    def index
      @clients = current_user.clients.order(:name)

      # Search by name
      if params[:search].present?
        search = "%#{params[:search]}%"
        @clients = @clients.where("name LIKE ?", search)
      end

      @clients = paginate(@clients, per_page: 20)
    end

    def show
      @client = current_user.clients.find(params[:id])
      @quotes = @client.quotes.order(created_at: :desc).limit(10)
      @invoices = @client.invoices.order(created_at: :desc).limit(10)

      @stats = {
        total_quotes: @client.quotes.count,
        total_invoices: @client.invoices.count,
        total_amount: @client.invoices.where(status: 'paid').sum(:total_amount),
        unpaid_amount: @client.invoices.unpaid.sum(:total_amount)
      }
    rescue ActiveRecord::RecordNotFound
      redirect_to client_clients_path, alert: t('client.clients.not_found')
    end
  end
end
