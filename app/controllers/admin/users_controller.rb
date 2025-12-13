# frozen_string_literal: true

module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [
      :show, :edit, :update,
      :suspend, :activate, :reset_whatsapp,
      :logs, :stripe_portal, :create_stripe_portal,
      :clients, :show_client, :edit_client,
      :quotes, :show_quote,
      :invoices, :show_invoice
    ]

    def index
      @users = User.all

      if params[:q].present?
        q = "%#{params[:q].to_s.strip}%"
        @users = @users.where(
          "company_name LIKE :q OR phone_number LIKE :q OR siret LIKE :q OR first_name LIKE :q OR last_name LIKE :q OR email LIKE :q",
          q: q
        )
      end

      @users = @users.where(subscription_status: params[:status]) if params[:status].present?
      @users = @users.where(preferred_language: params[:language]) if params[:language].present?

      if params[:whatsapp].present?
        case params[:whatsapp]
        when 'connected'
          @users = @users.where.not(unipile_chat_id: nil)
        when 'disconnected'
          @users = @users.where(unipile_chat_id: nil)
        end
      end

      @users = @users.order(created_at: :desc)
      @users = paginate(@users, per_page: 20)
    end

    def show
      @subscription = @user.subscriptions.order(created_at: :desc).first
      @quotes_count = @user.quotes.count
      @invoices_count = @user.invoices.count
      @clients_count = @user.clients.count
      @whatsapp_connected = @user.unipile_chat_id.present?
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(normalized_user_params)

      if params[:user].present? && params[:user][:account_status].present?
        @user.subscription_status = map_account_status(params[:user][:account_status])
      end

      if @user.save
        log_admin_action('admin_user_created', "User #{@user.id} created", { user_id: @user.id })
        redirect_to admin_user_path(@user), notice: 'Utilisateur créé avec succès.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @user.update(normalized_user_params)
        if params[:user].present? && params[:user][:account_status].present?
          @user.update(subscription_status: map_account_status(params[:user][:account_status]))
        end

        log_admin_action('admin_user_updated', "User #{@user.id} updated", { user_id: @user.id })
        redirect_to admin_user_path(@user), notice: 'Utilisateur mis à jour.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def suspend
      @user.update!(subscription_status: 'canceled')
      log_admin_action('user_suspended', "User #{@user.id} suspended", { user_id: @user.id })
      redirect_to admin_user_path(@user), notice: 'Utilisateur suspendu.'
    end

    def activate
      @user.update!(subscription_status: 'active')
      log_admin_action('user_activated', "User #{@user.id} activated", { user_id: @user.id })
      redirect_to admin_user_path(@user), notice: 'Utilisateur activé.'
    end

    def reset_whatsapp
      @user.update!(unipile_chat_id: nil, unipile_attendee_id: nil)
      log_admin_action('whatsapp_reset', "WhatsApp reset for user #{@user.id}", { user_id: @user.id })
      redirect_to admin_user_path(@user), notice: 'WhatsApp réinitialisé.'
    end

    def logs
      @logs = SystemLog.for_user(@user).recent

      if params[:q].present?
        q = "%#{params[:q].to_s.strip}%"
        @logs = @logs.where('event LIKE :q OR description LIKE :q', q: q)
      end

      @logs = @logs.where(log_type: params[:log_type]) if params[:log_type].present?
      @logs = paginate(@logs, per_page: 25)
    end

    def stripe_portal
      @subscription = @user.subscriptions.order(created_at: :desc).first
      @subscription_invoices = @user.subscription_invoices.order(created_at: :desc).limit(20)
    end

    def create_stripe_portal
      service = StripeService.new
      session = service.create_portal_session(user: @user, return_url: admin_user_url(@user))

      log_admin_action('stripe_portal_session_created', "Stripe portal session created for user #{@user.id}", { user_id: @user.id })
      redirect_to session.url, allow_other_host: true
    rescue StripeService::Error => e
      Rails.logger.error("Stripe portal error: #{e.message}")
      redirect_to stripe_portal_admin_user_path(@user), alert: "Erreur Stripe: #{e.message}"
    end

    # Nested views within a user
    def clients
      @clients = @user.clients

      if params[:q].present?
        q = "%#{params[:q].to_s.strip}%"
        @clients = @clients.where('name LIKE :q OR siret LIKE :q', q: q)
      end

      if params[:kind].present?
        @clients = params[:kind] == 'professional' ? @clients.where.not(siret: [nil, '']) : @clients.where(siret: [nil, ''])
      end

      @clients = @clients.order(created_at: :desc)
      @clients = paginate(@clients, per_page: 25)
    end

    def show_client
      @client = @user.clients.find(params[:client_id])
      @recent_quotes = @client.quotes.by_date.limit(5)
      @recent_invoices = @client.invoices.by_date.limit(5)
    end

    def edit_client
      @client = @user.clients.find(params[:client_id])
      # The view is currently mockup-only (no form_with). Kept for routing compatibility.
    end

    def quotes
      @quotes = @user.quotes.includes(:client)

      if params[:q].present?
        q = "%#{params[:q].to_s.strip}%"
        @quotes = @quotes.joins(:client).where('quotes.quote_number LIKE :q OR clients.name LIKE :q', q: q)
      end

      @quotes = @quotes.where(status: params[:status]) if params[:status].present?
      @quotes = @quotes.by_date
      @quotes = paginate(@quotes, per_page: 25)
    end

    def show_quote
      @quote = @user.quotes.includes(:client, :items).find(params[:quote_id])
    end

    def invoices
      @invoices = @user.invoices.includes(:client)

      if params[:q].present?
        q = "%#{params[:q].to_s.strip}%"
        @invoices = @invoices.joins(:client).where('invoices.invoice_number LIKE :q OR clients.name LIKE :q', q: q)
      end

      @invoices = @invoices.where(status: params[:status]) if params[:status].present?
      @invoices = @invoices.by_date
      @invoices = paginate(@invoices, per_page: 25)
    end

    def show_invoice
      @invoice = @user.invoices.includes(:client, :items, :quote).find(params[:invoice_id])
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :phone_number,
        :whatsapp_phone,
        :company_name,
        :siret,
        :address,
        :vat_number,
        :preferred_language,
        :stripe_customer_id
      )
    end

    # The admin mockup forms use whatsapp_phone, we map it to phone_number.
    def normalized_user_params
      attrs = user_params.to_h

      if attrs['phone_number'].blank? && attrs['whatsapp_phone'].present?
        attrs['phone_number'] = attrs.delete('whatsapp_phone')
      else
        attrs.delete('whatsapp_phone')
      end

      attrs
    end

    # The admin mockups use "suspended" while the core model uses subscription_status.
    def map_account_status(value)
      case value
      when 'active' then 'active'
      when 'pending' then 'pending'
      when 'suspended' then 'canceled'
      else 'pending'
      end
    end
  end
end
