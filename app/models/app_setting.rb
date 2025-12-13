# frozen_string_literal: true

# Singleton model for application-wide settings
# Access via AppSetting.instance
class AppSetting < ApplicationRecord
  # Encryption for sensitive fields
  encrypts :unipile_api_key_encrypted, deterministic: false
  encrypts :openai_api_key_encrypted, deterministic: false
  encrypts :stripe_secret_key_encrypted, deterministic: false
  encrypts :stripe_webhook_secret_encrypted, deterministic: false

  # Validations
  validates :signed_url_expiration_minutes, numericality: { greater_than: 0, less_than_or_equal_to: 1440 }
  validates :conversation_context_messages, numericality: { greater_than: 0, less_than_or_equal_to: 50 }
  validates :conversation_context_hours, numericality: { greater_than: 0, less_than_or_equal_to: 24 }
  validates :rate_limit_messages_per_hour, numericality: { greater_than: 0, less_than_or_equal_to: 500 }

  # Singleton pattern - only one record allowed
  class << self
    def instance
      first_or_create!
    end

    # Convenience methods for accessing settings
    delegate :unipile_configured?, :openai_configured?, :stripe_configured?,
             :unipile_account_id, :unipile_dsn, :unipile_api_key,
             :openai_api_key, :openai_model,
             :stripe_publishable_key, :stripe_secret_key, :stripe_price_id, :stripe_webhook_secret,
             :signed_url_expiration_minutes, :conversation_context_messages,
             :conversation_context_hours, :rate_limit_messages_per_hour,
             to: :instance
  end

  # Check if Unipile is properly configured
  def unipile_configured?
    unipile_account_id.present? && unipile_dsn.present? && unipile_api_key_encrypted.present?
  end

  # Check if OpenAI is properly configured
  def openai_configured?
    openai_api_key_encrypted.present?
  end

  # Check if Stripe is properly configured
  def stripe_configured?
    stripe_secret_key_encrypted.present? && stripe_price_id.present?
  end

  # Accessor for decrypted API keys (use these in services)
  def unipile_api_key
    unipile_api_key_encrypted
  end

  def unipile_api_key=(value)
    self.unipile_api_key_encrypted = value
  end

  def openai_api_key
    openai_api_key_encrypted
  end

  def openai_api_key=(value)
    self.openai_api_key_encrypted = value
  end

  def stripe_secret_key
    stripe_secret_key_encrypted
  end

  def stripe_secret_key=(value)
    self.stripe_secret_key_encrypted = value
  end

  def stripe_webhook_secret
    stripe_webhook_secret_encrypted
  end

  def stripe_webhook_secret=(value)
    self.stripe_webhook_secret_encrypted = value
  end
end
