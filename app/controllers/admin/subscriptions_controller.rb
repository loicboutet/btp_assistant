# frozen_string_literal: true

module Admin
  class SubscriptionsController < Admin::BaseController
    before_action :set_subscription, only: [:show, :edit, :update]
    before_action :load_users_for_select, only: [:new, :edit, :create, :update]

    def index
      @subscriptions = Subscription.includes(:user)

      if params[:q].present?
        q = "%#{params[:q].to_s.strip}%"
        @subscriptions = @subscriptions.joins(:user).where(
          'subscriptions.stripe_subscription_id LIKE :q OR users.stripe_customer_id LIKE :q OR users.company_name LIKE :q OR users.phone_number LIKE :q',
          q: q
        )
      end

      @subscriptions = @subscriptions.where(status: params[:status]) if params[:status].present?
      @subscriptions = @subscriptions.order(created_at: :desc)
      @subscriptions = paginate(@subscriptions, per_page: 25)

      # Summary stats for header (optional)
      @active_count = Subscription.active.count
      @past_due_count = Subscription.past_due.count
      @canceled_count = Subscription.canceled.count
    end

    def show
      @subscription_invoices = @subscription.subscription_invoices.order(created_at: :desc).limit(50)
    end

    def new
      @subscription = Subscription.new
    end

    def create
      @subscription = Subscription.new(subscription_params)

      if @subscription.save
        log_admin_action('admin_subscription_created', "Subscription #{@subscription.id} created", { subscription_id: @subscription.id, user_id: @subscription.user_id })
        redirect_to admin_subscription_path(@subscription), notice: 'Abonnement créé avec succès.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @subscription.update(subscription_params)
        log_admin_action('admin_subscription_updated', "Subscription #{@subscription.id} updated", { subscription_id: @subscription.id, user_id: @subscription.user_id })
        redirect_to admin_subscription_path(@subscription), notice: 'Abonnement mis à jour.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def overdue
      @subscriptions = Subscription.past_due.includes(:user)

      if params[:q].present?
        q = "%#{params[:q].to_s.strip}%"
        @subscriptions = @subscriptions.joins(:user).where(
          'subscriptions.stripe_subscription_id LIKE :q OR users.stripe_customer_id LIKE :q OR users.company_name LIKE :q OR users.phone_number LIKE :q',
          q: q
        )
      end

      @subscriptions = @subscriptions.order(updated_at: :desc)
      @subscriptions = paginate(@subscriptions, per_page: 25)
    end

    private

    def set_subscription
      @subscription = Subscription.includes(:user).find(params[:id])
    end

    def load_users_for_select
      @users_for_select = User.order(created_at: :desc).limit(200)
    end

    def subscription_params
      params.require(:subscription).permit(
        :user_id,
        :stripe_subscription_id,
        :stripe_price_id,
        :status,
        :current_period_start,
        :current_period_end,
        :cancel_at_period_end,
        :canceled_at
      )
    end
  end
end
