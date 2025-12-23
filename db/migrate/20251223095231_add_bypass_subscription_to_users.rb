class AddBypassSubscriptionToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :bypass_subscription, :boolean, default: false, null: false
  end
end
