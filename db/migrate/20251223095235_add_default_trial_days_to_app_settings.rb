class AddDefaultTrialDaysToAppSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :app_settings, :default_trial_days, :integer, default: 14
  end
end
