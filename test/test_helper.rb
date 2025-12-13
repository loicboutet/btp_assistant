ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"
require "mocha/minitest"
require "minitest/mock"

# Support files (helpers, base classes...)
Dir[Rails.root.join('test/support/**/*.rb')].sort.each { |f| require f }

# Allow localhost connections for system tests
WebMock.disable_net_connect!(allow_localhost: true)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Fixture class mapping (admins table = AdminUser model, not Admin namespace module)
    set_fixture_class admins: AdminUser

    # Add more helper methods to be used by all tests here...
  end
end
