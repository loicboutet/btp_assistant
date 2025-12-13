# frozen_string_literal: true

class CreateAppSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :app_settings do |t|
      # Unipile Configuration
      t.string :unipile_account_id
      t.string :unipile_dsn
      t.string :unipile_api_key_encrypted
      t.string :whatsapp_business_number

      # OpenAI Configuration
      t.string :openai_api_key_encrypted
      t.string :openai_model, default: 'gpt-4'

      # Stripe Configuration
      t.string :stripe_publishable_key
      t.string :stripe_secret_key_encrypted
      t.string :stripe_price_id
      t.string :stripe_webhook_secret_encrypted

      # App Configuration
      t.integer :signed_url_expiration_minutes, default: 30
      t.integer :conversation_context_messages, default: 15
      t.integer :conversation_context_hours, default: 2
      t.integer :rate_limit_messages_per_hour, default: 50

      t.timestamps
    end
  end
end
