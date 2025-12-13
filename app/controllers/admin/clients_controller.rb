# frozen_string_literal: true

module Admin
  class ClientsController < Admin::BaseController
    def index
      @clients = Client.includes(:user)

      if params[:q].present?
        q = "%#{params[:q].strip}%"
        @clients = @clients.joins(:user).where(
          "clients.name LIKE :q OR clients.siret LIKE :q OR clients.address LIKE :q OR users.company_name LIKE :q",
          q: q
        )
      end

      if params[:kind].present?
        @clients = params[:kind] == 'professional' ? @clients.where.not(siret: [nil, '']) : @clients.where(siret: [nil, ''])
      end

      @clients = @clients.where(user_id: params[:user_id]) if params[:user_id].present?

      @clients = @clients.order(created_at: :desc)
      @clients = paginate(@clients, per_page: 25)

      @users_for_filter = User.order(:company_name)
    end

    def show
      @client = Client.includes(:user, :quotes, :invoices).find(params[:id])
    end
  end
end
