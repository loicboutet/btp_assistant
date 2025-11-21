Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  # ========================================
  # Devise Routes
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
  get 'sign_up/success', to: 'registrations#success', as: :registration_success

  # ========================================
  # Client Routes
  # ========================================
  get 'dashboard', to: 'dashboard#index', as: :client_dashboard
  get 'profile', to: 'profile#show', as: :client_profile
  patch 'profile', to: 'profile#update'

  get 'whatsapp/connect', to: 'whatsapp#connect', as: :whatsapp_connect
  post 'whatsapp/connect', to: 'whatsapp#create'
  get 'whatsapp/status', to: 'whatsapp#status', as: :whatsapp_status
  delete 'whatsapp/disconnect', to: 'whatsapp#disconnect', as: :whatsapp_disconnect

  resources :clients
  
  resources :quotes, only: [:index, :show, :edit, :update, :destroy] do
    member do
      get :pdf
      get :preview
      post :send_whatsapp
    end
  end

  resources :invoices, only: [:index, :show, :destroy] do
    member do
      get :pdf
      get :preview
      post :send_whatsapp
      patch :status
    end
  end

  resources :conversations, only: [:index, :show]
  post 'subscription/portal', to: 'subscriptions#portal', as: :client_subscription

  # ========================================
  # Admin Routes
  # ========================================
  namespace :admin do
    root to: 'dashboard#index', as: :dashboard
    get 'metrics', to: 'dashboard#metrics'

    resources :users, only: [:index, :show, :new, :create, :edit, :update] do
      member do
        post :suspend
        post :activate
        post :reset_whatsapp
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

    resources :subscriptions, only: [:index, :show] do
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

    get 'settings', to: 'settings#index', as: :settings
    get 'settings/unipile', to: 'settings#unipile'
    get 'settings/stripe', to: 'settings#stripe_config'
    get 'settings/openai', to: 'settings#openai_config'
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
