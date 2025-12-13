class RenameUsersToAdmins < ActiveRecord::Migration[8.0]
  def change
    # Rename the users table to admins
    rename_table :users, :admins

    # Rename the indexes accordingly
    rename_index :admins, 'index_users_on_email', 'index_admins_on_email'
    rename_index :admins, 'index_users_on_reset_password_token', 'index_admins_on_reset_password_token'
  end
end
