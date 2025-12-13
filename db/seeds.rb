# Seeds (idempotent)

# Ensure singleton settings exists
AppSetting.instance

# Ensure default prompts exist
LlmPrompt.seed_defaults!

# Optional: create a default admin in development (change password!)
if Rails.env.development?
  Admin.find_or_create_by!(email: 'admin@example.com') do |a|
    a.password = 'password123'
    a.password_confirmation = 'password123'
  end
end
