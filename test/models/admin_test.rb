# frozen_string_literal: true

require "test_helper"

class AdminTest < ActiveSupport::TestCase
  test "should not save admin without email" do
    admin = AdminUser.new(password: "password123")
    assert_not admin.save, "Saved the admin without an email"
  end

  test "should not save admin without password" do
    admin = AdminUser.new(email: "test@example.com")
    assert_not admin.save, "Saved the admin without a password"
  end

  test "should save valid admin" do
    admin = AdminUser.new(email: "test@example.com", password: "password123")
    assert admin.save, "Could not save a valid admin"
  end

  test "should not save admin with duplicate email" do
    AdminUser.create!(email: "duplicate@example.com", password: "password123")
    admin = AdminUser.new(email: "duplicate@example.com", password: "password456")
    assert_not admin.save, "Saved an admin with a duplicate email"
  end
end
