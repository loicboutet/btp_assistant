Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  # ========================================
  # Admin Devise Routes (Back-office users)
  # ========================================
  devise_for :admins, class_name: 'AdminUser', controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations',
    passwords: 'admins/passwords'
  }, path: 'admin', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'sign_up'
  }

  # ========================================
  # Signed URL Access for Artisans (Users)
  # ========================================
  get 'u/:token', to: 'user_sessions#show', as: :signed_user_access

  # ========================================
  # Payment Pages (Stripe redirect)
  # ========================================
  get 'payment/success', to: 'payment#success'
  get 'payment/canceled', to: 'payment#canceled'

  # ========================================
  # Public Routes
  # ========================================
  get 'legal', to: 'pages#legal'
  get 'terms', to: 'pages#terms'
  get 'privacy', to: 'pages#privacy'
  get 'about', to: 'pages#about'
  get 'support', to: 'pages#support'
  get 'contact', to: 'pages#contact'

  # ========================================
  # Client Routes (Artisan Web Interface)
  # IMPORTANT: We keep the URL helpers prefix as `client_*` for backwards compatibility,
  # but the controllers are now namespaced under `Portal::` to avoid collision with the
  # `Client` model.
  # ========================================
  scope module: 'portal', as: 'client' do
    get 'dashboard', to: 'dashboard#index'
    get 'profile', to: 'profile#show'
    patch 'profile', to: 'profile#update'
    post 'profile/billing_portal', to: 'profile#billing_portal', as: :billing_portal

    resources :quotes, only: [:index, :show] do
      member do
        get :pdf
        post :send_whatsapp
      end
    end

    resources :invoices, only: [:index, :show] do
      member do
        get :pdf
        post :send_whatsapp
      end
    end

    resources :clients, only: [:index, :show]
  end

  # ========================================
  # Admin Routes (Back-office)
  # ========================================
  namespace :admin do
    root to: 'dashboard#index', as: :dashboard
    get 'metrics', to: 'dashboard#metrics'

    resources :users, only: [:index, :show, :new, :create, :edit, :update] do
      member do
        post :suspend
        post :activate
        post :reset_whatsapp
        post :toggle_bypass
        get :logs
        get :stripe_portal
        post :create_stripe_portal

        get :clients
        get 'clients/:client_id', to: 'users#show_client', as: :client
        get 'clients/:client_id/edit', to: 'users#edit_client', as: :edit_client
        get :quotes
        get 'quotes/:quote_id', to: 'users#show_quote', as: :quote
        get :invoices
        get 'invoices/:invoice_id', to: 'users#show_invoice', as: :invoice
      end
    end

    resources :subscriptions, only: [:index, :show, :new, :create, :edit, :update] do
      collection do
        get :overdue
      end
    end

    resources :webhooks, only: [:index] do
      member do
        get :replay
        post :replay
      end
    end

    # Global Data Views
    resources :clients, only: [:index, :show]
    resources :quotes, only: [:index, :show]
    resources :invoices, only: [:index, :show]

    # Settings
    get 'settings', to: 'settings#index', as: :settings
    patch 'settings', to: 'settings#update'
    get 'settings/unipile', to: 'settings#unipile'
    patch 'settings/unipile', to: 'settings#update_unipile'
    get 'settings/stripe', to: 'settings#stripe_config'
    patch 'settings/stripe', to: 'settings#update_stripe'
    get 'settings/openai', to: 'settings#openai_config'
    patch 'settings/openai', to: 'settings#update_openai'
    post 'settings/test_connection', to: 'settings#test_connection'

    # LLM Prompts Management
    resources :prompts, only: [:index, :edit, :update] do
      member do
        post :test
      end
    end

    # System Logs
    resources :system_logs, only: [:index, :show]

    # Legacy alias: certaines maquettes utilisaient /admin/logs
    # On mappe volontairement sur SystemLogsController pour éviter toute incohérence.
    resources :logs, only: [:index, :show], controller: :system_logs

    # WhatsApp Monitoring
    resources :whatsapp_messages, only: [:index, :show]
    resources :llm_conversations, only: [:index, :show]
  end

  # ========================================
  # Webhooks (API)
  # ========================================
  namespace :webhooks do
    namespace :unipile do
      post 'messages', to: 'messages#create'
      post 'accounts', to: 'accounts#create'
    end
    post 'stripe', to: 'stripe#create'
  end

  # ========================================
  # Mockups (Dev only)
  # ========================================
  if Rails.env.development? || Rails.env.staging?
    get 'mockups', to: 'mockups#index'
    get 'mockups/admin_dashboard', to: 'mockups#admin_dashboard'
    get 'mockups/admin_users', to: 'mockups#admin_users'
    get 'mockups/admin_analytics', to: 'mockups#admin_analytics'
    get 'mockups/user_dashboard', to: 'mockups#user_dashboard'
    get 'mockups/user_quotes_list', to: 'mockups#user_quotes_list'
    get 'mockups/user_profile', to: 'mockups#user_profile'
    get 'mockups/signup_success', to: 'mockups#signup_success'
    get 'mockups/user_settings', to: 'mockups#user_settings'
  end
end
