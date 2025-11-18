Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by uptime monitors and load balancers.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"

  # ========================================
  # Devise Routes (Authentication)
  # ========================================
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'sign_up'
  }

  # ========================================
  # Public Routes
  # ========================================
  get 'legal', to: 'pages#legal'
  get 'terms', to: 'pages#terms'
  get 'privacy', to: 'pages#privacy'
  get 'about', to: 'pages#about'
  get 'support', to: 'pages#support'
  get 'contact', to: 'pages#contact'

  # Registration Journey
  get 'sign_up/success', to: 'registrations#success', as: :registration_success

  # ========================================
  # Authenticated User Routes
  # ========================================
  # Dashboard
  get 'dashboard', to: 'dashboard#index', as: :client_dashboard
  
  # Profile
  get 'profile', to: 'profile#show', as: :client_profile
  patch 'profile', to: 'profile#update'

  # WhatsApp Connection
  get 'whatsapp/connect', to: 'whatsapp#connect', as: :whatsapp_connect
  post 'whatsapp/connect', to: 'whatsapp#create'
  get 'whatsapp/status', to: 'whatsapp#status', as: :whatsapp_status
  delete 'whatsapp/disconnect', to: 'whatsapp#disconnect', as: :whatsapp_disconnect

  # Clients Management
  resources :clients do
    member do
      get :edit, as: :edit_client
    end
  end

  # Quotes Management
  resources :quotes, only: [:index, :show] do
    member do
      get :pdf, as: :quote_pdf
      get :preview, as: :quote_preview
      post :send_whatsapp, as: :send_quote_whatsapp
    end
  end

  # Invoices Management
  resources :invoices, only: [:index, :show] do
    member do
      get :pdf, as: :invoice_pdf
      get :preview, as: :invoice_preview
      post :send_whatsapp, as: :send_invoice_whatsapp
      patch :status, as: :update_invoice_status
    end
  end

  # Conversations
  resources :conversations, only: [:index, :show]

  # Subscription Management (Stripe Portal)
  post 'subscription/portal', to: 'subscriptions#portal', as: :client_subscription

  # ========================================
  # Admin Routes
  # ========================================
  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    get 'metrics', to: 'dashboard#metrics'

    # User Management
    resources :users, only: [:index, :show, :new, :create, :edit, :update] do
      member do
        post :suspend
        post :activate
        post :reset_whatsapp
        get :logs
        get :stripe_portal
        post :create_stripe_portal
      end
    end

    # Subscription Management
    resources :subscriptions, only: [:index, :show] do
      collection do
        get :overdue
      end
    end

    # System Monitoring
    resources :logs, only: [:index, :show]
    
    resources :webhooks, only: [:index] do
      member do
        get :replay
        post :replay
      end
    end

    # Settings
    get 'settings', to: 'settings#index'
    patch 'settings', to: 'settings#update'
    get 'settings/unipile', to: 'settings#unipile'
    post 'settings/unipile/test', to: 'settings#test_unipile'
    get 'settings/stripe', to: 'settings#stripe_config'
    get 'settings/openai', to: 'settings#openai_config'
  end

  # ========================================
  # Webhook Routes (API)
  # ========================================
  namespace :webhooks do
    namespace :unipile do
      post 'messages', to: 'messages#create'
      post 'accounts', to: 'accounts#create'
    end

    post 'stripe', to: 'stripe#create'
  end

  # ========================================
  # Mockups Routes (for development/preview)
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
