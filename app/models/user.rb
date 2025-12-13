# frozen_string_literal: true

# User model for artisans (BTP entrepreneurs)
# Identity is based on phone number - NO password authentication
# Web access is via signed URLs sent on WhatsApp
class User < ApplicationRecord
  # Associations
  has_many :clients, dependent: :destroy
  has_many :quotes, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :whatsapp_messages, dependent: :destroy
  has_many :llm_conversations, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscription_invoices, dependent: :destroy
  has_many :system_logs, dependent: :nullify

  # Validations
  validates :phone_number, presence: true, uniqueness: true
  validates :phone_number, format: { 
    with: /\A\+[1-9]\d{1,14}\z/, 
    message: "must be in E.164 format (e.g., +33612345678)" 
  }
  validates :subscription_status, inclusion: { 
    in: %w[pending active past_due canceled],
    message: "%{value} is not a valid status" 
  }
  validates :preferred_language, inclusion: { 
    in: %w[fr tr],
    message: "%{value} is not supported (use 'fr' or 'tr')" 
  }

  # Scopes
  scope :active, -> { where(subscription_status: 'active') }
  scope :pending, -> { where(subscription_status: 'pending') }
  scope :past_due, -> { where(subscription_status: 'past_due') }
  scope :can_create_documents, -> { where(subscription_status: %w[active past_due]) }

  # Callbacks
  before_validation :normalize_phone_number

  # Subscription status helpers
  def active?
    subscription_status == 'active'
  end

  def pending?
    subscription_status == 'pending'
  end

  def past_due?
    subscription_status == 'past_due'
  end

  def canceled?
    subscription_status == 'canceled'
  end

  def can_create_documents?
    active? || past_due?
  end

  def needs_payment?
    pending? || canceled?
  end

  # Activity tracking
  def record_activity!
    update_column(:last_activity_at, Time.current)
  end

  def record_first_message!
    update_column(:first_message_at, Time.current) if first_message_at.nil?
  end

  # Onboarding helpers
  def onboarding_complete?
    onboarding_completed? && company_name.present? && siret.present? && address.present?
  end

  def complete_onboarding!
    update!(onboarding_completed: true) if company_name.present?
  end

  # Display helpers
  def display_name
    company_name.presence || phone_number
  end

  def formatted_phone
    # Simple formatting for French numbers
    if phone_number&.start_with?('+33')
      phone_number.gsub(/\A\+33(\d)(\d{2})(\d{2})(\d{2})(\d{2})\z/, '0\1 \2 \3 \4 \5')
    else
      phone_number
    end
  end

  # Language helpers
  def french?
    preferred_language == 'fr'
  end

  def turkish?
    preferred_language == 'tr'
  end

  private

  def normalize_phone_number
    return if phone_number.blank?
    
    # Remove spaces and dashes
    normalized = phone_number.gsub(/[\s\-\.\(\)]/, '')
    
    # Add + if missing
    normalized = "+#{normalized}" unless normalized.start_with?('+')
    
    # Convert French format 06... to +336...
    normalized = normalized.sub(/\A\+?0/, '+33') if normalized.match?(/\A\+?0[67]/)
    
    self.phone_number = normalized
  end
end
