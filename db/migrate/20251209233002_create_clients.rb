# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.references :user, null: false, foreign_key: true

      t.string :name, null: false
      t.text :address
      t.string :siret
      t.string :contact_phone
      t.string :contact_email
      t.string :created_via, default: 'whatsapp'

      t.timestamps
    end

    add_index :clients, [:user_id, :name]
  end
end
