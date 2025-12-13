# frozen_string_literal: true

module Admin
  class InvoicesController < Admin::BaseController
    def index
      @invoices = Invoice.includes(:user, :client)

      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @invoices = @invoices.joins(:client, :user).where(
          "invoices.invoice_number LIKE :q OR clients.name LIKE :q OR users.company_name LIKE :q",
          q: q
        )
      end

      @invoices = @invoices.where(status: params[:status]) if params[:status].present?
      @invoices = @invoices.where(user_id: params[:user_id]) if params[:user_id].present?

      if params[:period].present?
        from = case params[:period]
               when 'today' then Time.current.beginning_of_day
               when 'week' then 7.days.ago
               when 'month' then 1.month.ago
               when 'quarter' then 3.months.ago
               end
        @invoices = @invoices.where('invoices.created_at >= ?', from) if from
      end

      @invoices = @invoices.by_date
      @invoices = paginate(@invoices, per_page: 25)

      @users_for_filter = User.order(:company_name)
    end

    def show
      @invoice = Invoice.includes(:user, :client, :items, :quote).find(params[:id])
    end
  end
end
