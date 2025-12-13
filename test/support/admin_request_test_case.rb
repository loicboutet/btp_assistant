# frozen_string_literal: true

require 'test_helper'

# Base class pour les request tests Admin.
# Inclut un helper de login Devise (via POST /admin/login)
class AdminRequestTestCase < ActionDispatch::IntegrationTest
  include AdminIntegrationHelpers

  setup do
    # S'assure qu'on a un AppSetting pour les pages settings
    AppSetting.instance
  end
end
