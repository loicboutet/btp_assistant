class AddDetailsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :whatsapp_phone, :string
    add_column :users, :company_name, :string
    add_column :users, :siret, :string
    add_column :users, :address, :text
    add_column :users, :vat_number, :string
    add_column :users, :preferred_language, :string
  end
end
