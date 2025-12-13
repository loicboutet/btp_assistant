# frozen_string_literal: true

class CreateQuotes < ActiveRecord::Migration[8.0]
  def change
    create_table :quotes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true

      # Quote identification
      t.string :quote_number, null: false
      t.date :issue_date, null: false
      t.date :validity_date

      # Status
      t.string :status, default: 'draft'

      # Amounts
      t.decimal :subtotal_amount, precision: 10, scale: 2, default: 0
      t.decimal :vat_rate, precision: 5, scale: 2, default: 20.0
      t.decimal :vat_amount, precision: 10, scale: 2, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, default: 0

      # Additional info
      t.text :notes
      t.datetime :sent_via_whatsapp_at

      t.timestamps
    end

    add_index :quotes, :quote_number, unique: true
    add_index :quotes, [:user_id, :issue_date]
    add_index :quotes, :status
  end
end
