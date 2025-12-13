# frozen_string_literal: true

class FixQuoteInvoiceNumberUniqueness < ActiveRecord::Migration[8.0]
  def change
    # Remove global unique indexes
    remove_index :quotes, :quote_number
    remove_index :invoices, :invoice_number
    
    # Add compound unique indexes (unique per user)
    add_index :quotes, [:user_id, :quote_number], unique: true
    add_index :invoices, [:user_id, :invoice_number], unique: true
  end
end
