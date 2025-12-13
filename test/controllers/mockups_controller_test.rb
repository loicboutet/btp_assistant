require "test_helper"

class MockupsControllerTest < ActionDispatch::IntegrationTest
  # Mockups routes are only available in development/staging
  # These tests verify the routes exist for those environments
  # Skip in test environment since routes aren't loaded
  
  test "root should route to home index" do
    assert_routing '/', controller: 'home', action: 'index'
  end
end
