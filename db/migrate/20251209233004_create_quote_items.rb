# frozen_string_literal: true

class CreateQuoteItems < ActiveRecord::Migration[8.0]
  def change
    create_table :quote_items do |t|
      t.references :quote, null: false, foreign_key: true

      t.text :description, null: false
      t.decimal :quantity, precision: 10, scale: 2, default: 1
      t.string :unit, default: 'unité'
      t.decimal :unit_price, precision: 10, scale: 2, default: 0
      t.decimal :total_price, precision: 10, scale: 2, default: 0
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :quote_items, [:quote_id, :position]
  end
end
