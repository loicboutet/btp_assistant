# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    # Use unique phone numbers to avoid fixture conflicts
    @user = User.new(
      phone_number: "+33666778899",
      company_name: "Test BTP User Model",
      siret: "12345678901234",
      address: "123 Rue Test, 75001 Paris",
      preferred_language: "fr"
    )
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should not be valid without phone_number" do
    @user.phone_number = nil
    assert_not @user.valid?
    assert_includes @user.errors[:phone_number], "can't be blank"
  end

  test "should not be valid with invalid phone format" do
    @user.phone_number = "invalid"
    assert_not @user.valid?
    assert_includes @user.errors[:phone_number], "must be in E.164 format (e.g., +33612345678)"
  end

  test "should not be valid with duplicate phone_number" do
    @user.save!
    duplicate = User.new(phone_number: "+33666778899")
    assert_not duplicate.valid?
  end

  test "should validate subscription_status values" do
    @user.subscription_status = "invalid"
    assert_not @user.valid?
    assert_includes @user.errors[:subscription_status], "invalid is not a valid status"
  end

  test "should validate preferred_language values" do
    @user.preferred_language = "en"
    assert_not @user.valid?
    assert_includes @user.errors[:preferred_language], "en is not supported (use 'fr' or 'tr')"
  end

  # Phone normalization tests
  test "should normalize French phone number" do
    @user.phone_number = "06 66 77 88 99"
    @user.valid?
    assert_equal "+33666778899", @user.phone_number
  end

  test "should add + prefix if missing" do
    @user.phone_number = "33666778899"
    @user.valid?
    assert_equal "+33666778899", @user.phone_number
  end

  # Status helper tests
  test "should be pending by default" do
    assert @user.pending?
    assert_equal "pending", @user.subscription_status
  end

  test "should identify active users" do
    @user.subscription_status = "active"
    assert @user.active?
    assert @user.can_create_documents?
    assert_not @user.needs_payment?
  end

  test "should identify past_due users" do
    @user.subscription_status = "past_due"
    assert @user.past_due?
    assert @user.can_create_documents?
  end

  test "should identify canceled users" do
    @user.subscription_status = "canceled"
    assert @user.canceled?
    assert_not @user.can_create_documents?
    assert @user.needs_payment?
  end

  # Language helper tests
  test "should identify French users" do
    @user.preferred_language = "fr"
    assert @user.french?
    assert_not @user.turkish?
  end

  test "should identify Turkish users" do
    @user.preferred_language = "tr"
    assert @user.turkish?
    assert_not @user.french?
  end

  # Display helper tests
  test "should display company name if present" do
    assert_equal "Test BTP User Model", @user.display_name
  end

  test "should display phone if no company name" do
    @user.company_name = nil
    assert_equal "+33666778899", @user.display_name
  end

  # Onboarding tests
  test "should not be onboarding complete without required fields" do
    @user.onboarding_completed = true
    @user.siret = nil
    assert_not @user.onboarding_complete?
  end

  test "should be onboarding complete with all fields" do
    @user.onboarding_completed = true
    assert @user.onboarding_complete?
  end
end
