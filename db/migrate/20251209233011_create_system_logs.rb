# frozen_string_literal: true

class CreateSystemLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :system_logs do |t|
      t.references :user, foreign_key: true
      t.references :admin, foreign_key: true

      t.string :log_type, null: false  # info/warning/error/audit
      t.string :event, null: false
      t.text :description
      t.json :metadata

      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :system_logs, [:log_type, :created_at]
    add_index :system_logs, :event
    add_index :system_logs, :created_at
  end
end
