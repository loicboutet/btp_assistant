# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      # Identity - Phone number is the unique identifier
      t.string :phone_number, null: false

      # Company Information
      t.string :company_name
      t.string :siret
      t.text :address
      t.string :vat_number
      t.string :preferred_language, default: 'fr'

      # Stripe Integration
      t.string :stripe_customer_id

      # Subscription Status
      t.string :subscription_status, default: 'pending'
      t.boolean :onboarding_completed, default: false

      # Activity Tracking
      t.datetime :first_message_at
      t.datetime :last_activity_at

      # Unipile Integration
      t.string :unipile_chat_id
      t.string :unipile_attendee_id

      t.timestamps
    end

    add_index :users, :phone_number, unique: true
    add_index :users, :stripe_customer_id
    add_index :users, :unipile_chat_id
    add_index :users, :unipile_attendee_id
    add_index :users, :subscription_status
  end
end
