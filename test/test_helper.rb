ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

# Fixture users get a fresh random password on every run. A well-known one like
# "password" makes Chrome's password manager open its leaked-password warning in
# system tests, which then swallows clicks and keystrokes meant for the page.
TEST_PASSWORD = SecureRandom.base58(24)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
