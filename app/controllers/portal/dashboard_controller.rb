# frozen_string_literal: true

module Portal
  class DashboardController < Portal::BaseController
    def index
      @quotes_count = current_user.quotes.count
      @invoices_count = current_user.invoices.count
      @clients_count = current_user.clients.count
      @total_revenue = current_user.invoices.where(status: 'paid').sum(:total_amount)

      @recent_quotes = current_user.quotes
                                   .includes(:client)
                                   .order(created_at: :desc)
                                   .limit(5)

      @recent_invoices = current_user.invoices
                                     .includes(:client)
                                     .order(created_at: :desc)
                                     .limit(5)

      @stats = {
        quotes_count: @quotes_count,
        quotes_this_month: current_user.quotes.where('created_at >= ?', Date.current.beginning_of_month).count,
        invoices_count: @invoices_count,
        invoices_this_month: current_user.invoices.where('created_at >= ?', Date.current.beginning_of_month).count,
        unpaid_invoices: current_user.invoices.unpaid.count,
        total_revenue: @total_revenue
      }
    end
  end
end
