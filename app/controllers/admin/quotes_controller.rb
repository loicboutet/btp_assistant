# frozen_string_literal: true

module Admin
  class QuotesController < Admin::BaseController
    def index
      @quotes = Quote.includes(:user, :client)

      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @quotes = @quotes.joins(:client, :user).where(
          "quotes.quote_number LIKE :q OR clients.name LIKE :q OR users.company_name LIKE :q",
          q: q
        )
      end

      @quotes = @quotes.where(status: params[:status]) if params[:status].present?
      @quotes = @quotes.where(user_id: params[:user_id]) if params[:user_id].present?

      if params[:period].present?
        from = case params[:period]
               when 'today' then Time.current.beginning_of_day
               when 'week' then 7.days.ago
               when 'month' then 1.month.ago
               when 'quarter' then 3.months.ago
               end
        @quotes = @quotes.where('quotes.created_at >= ?', from) if from
      end

      @quotes = @quotes.by_date
      @quotes = paginate(@quotes, per_page: 25)

      @users_for_filter = User.order(:company_name)
    end

    def show
      @quote = Quote.includes(:user, :client, :items).find(params[:id])
    end
  end
end
