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
    assert @user.subscription_active?
    assert_not @user.needs_payment?
  end

  test "should identify past_due users" do
    @user.subscription_status = "past_due"
    assert @user.past_due?
    assert @user.subscription_active?
  end

  test "should identify canceled users" do
    @user.subscription_status = "canceled"
    assert @user.canceled?
    assert_not @user.subscription_active?
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

  # ===========================================
  # Trial Period Tests
  # ===========================================

  test "in_trial_period? returns true when trial_ends_at is in the future" do
    @user.trial_ends_at = 7.days.from_now
    assert @user.in_trial_period?
  end

  test "in_trial_period? returns false when trial_ends_at is in the past" do
    @user.trial_ends_at = 1.day.ago
    assert_not @user.in_trial_period?
  end

  test "in_trial_period? returns false when trial_ends_at is nil" do
    @user.trial_ends_at = nil
    assert_not @user.in_trial_period?
  end

  test "trial_expired? returns true when trial_ends_at is in the past" do
    @user.trial_ends_at = 1.day.ago
    assert @user.trial_expired?
  end

  test "trial_expired? returns false when trial_ends_at is in the future" do
    @user.trial_ends_at = 7.days.from_now
    assert_not @user.trial_expired?
  end

  test "trial_expired? returns false when trial_ends_at is nil" do
    @user.trial_ends_at = nil
    assert_not @user.trial_expired?
  end

  test "trial_days_remaining returns correct number of days" do
    @user.trial_ends_at = 7.days.from_now
    assert_equal 7, @user.trial_days_remaining
  end

  test "trial_days_remaining returns 0 when trial has expired" do
    @user.trial_ends_at = 1.day.ago
    assert_equal 0, @user.trial_days_remaining
  end

  test "trial_days_remaining returns 0 when trial_ends_at is nil" do
    @user.trial_ends_at = nil
    assert_equal 0, @user.trial_days_remaining
  end

  test "trial_days_remaining rounds up partial days" do
    @user.trial_ends_at = 2.5.days.from_now
    assert_equal 3, @user.trial_days_remaining
  end

  # can_create_documents? with trial period tests
  test "can_create_documents? returns true during trial period even without subscription" do
    @user.subscription_status = "pending"
    @user.trial_ends_at = 7.days.from_now
    assert @user.can_create_documents?
  end

  test "can_create_documents? returns false after trial expires without subscription" do
    @user.subscription_status = "pending"
    @user.trial_ends_at = 1.day.ago
    assert_not @user.can_create_documents?
  end

  test "can_create_documents? returns true with active subscription even if trial expired" do
    @user.subscription_status = "active"
    @user.trial_ends_at = 1.day.ago
    assert @user.can_create_documents?
  end

  test "can_create_documents? returns true with past_due subscription" do
    @user.subscription_status = "past_due"
    @user.trial_ends_at = 1.day.ago
    assert @user.can_create_documents?
  end

  test "can_create_documents? returns false for canceled user with expired trial" do
    @user.subscription_status = "canceled"
    @user.trial_ends_at = 1.day.ago
    assert_not @user.can_create_documents?
  end

  # set_trial_period callback tests
  test "set_trial_period callback sets trial_ends_at on create" do
    # Use unique phone number that doesn't conflict with fixtures
    user = User.create!(
      phone_number: "+33699887711",
      preferred_language: "fr"
    )
    
    assert_not_nil user.trial_ends_at
    # Should be approximately 14 days from now (default trial days)
    expected_trial_end = 14.days.from_now
    assert_in_delta expected_trial_end.to_i, user.trial_ends_at.to_i, 60 # Within 1 minute
  end

  test "set_trial_period callback does not overwrite existing trial_ends_at" do
    custom_trial_end = 30.days.from_now
    user = User.new(
      phone_number: "+33699887722",
      preferred_language: "fr",
      trial_ends_at: custom_trial_end
    )
    user.save!
    
    # The trial_ends_at should remain at the custom value
    assert_in_delta custom_trial_end.to_i, user.trial_ends_at.to_i, 60
  end

  test "set_trial_period uses AppSetting default_trial_days" do
    # Ensure AppSetting has default_trial_days set
    setting = AppSetting.instance
    original_trial_days = setting.default_trial_days
    setting.update!(default_trial_days: 7)
    
    user = User.create!(
      phone_number: "+33699887733",
      preferred_language: "fr"
    )
    
    expected_trial_end = 7.days.from_now
    assert_in_delta expected_trial_end.to_i, user.trial_ends_at.to_i, 60
    
    # Restore original value
    setting.update!(default_trial_days: original_trial_days)
  end

  # in_trial scope test
  test "in_trial scope returns only users with active trial" do
    # Create user in trial
    user_in_trial = User.create!(
      phone_number: "+33699887744",
      preferred_language: "fr",
      trial_ends_at: 7.days.from_now
    )
    
    # Create user with expired trial
    user_expired = User.create!(
      phone_number: "+33699887755",
      preferred_language: "fr",
      trial_ends_at: 1.day.ago
    )
    
    in_trial_users = User.in_trial
    
    assert_includes in_trial_users, user_in_trial
    assert_not_includes in_trial_users, user_expired
  end
end
