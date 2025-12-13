# frozen_string_literal: true

class AddIdentityFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :email, :string

    add_index :users, :email
  end
end
