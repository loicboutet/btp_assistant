# frozen_string_literal: true

class CreateSubscriptionInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscription, foreign_key: true

      t.string :stripe_invoice_id, null: false
      t.string :invoice_number
      t.decimal :amount, precision: 10, scale: 2
      t.string :currency, default: 'eur'
      t.string :status

      t.date :period_start
      t.date :period_end
      t.datetime :paid_at

      t.string :stripe_invoice_url
      t.string :stripe_invoice_pdf

      t.timestamps
    end

    add_index :subscription_invoices, :stripe_invoice_id, unique: true
    add_index :subscription_invoices, :invoice_number
  end
end
