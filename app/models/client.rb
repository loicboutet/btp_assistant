# frozen_string_literal: true

# Client model - represents customers of the artisans
# Created via WhatsApp conversations or web interface
class Client < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :quotes, dependent: :restrict_with_error
  has_many :invoices, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, message: "already exists for this user" }
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :siret, format: { with: /\A\d{14}\z/, message: "must be 14 digits" }, allow_blank: true

  # Scopes
  scope :search, ->(query) { where("name ILIKE ?", "%#{query}%") if query.present? }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_name, -> { order(:name) }
  scope :created_via_whatsapp, -> { where(created_via: 'whatsapp') }
  scope :created_via_web, -> { where(created_via: 'web') }

  # Callbacks
  before_validation :normalize_siret

  # Financial helpers
  def total_quotes_amount
    quotes.sum(:total_amount)
  end

  def total_invoices_amount
    invoices.sum(:total_amount)
  end

  def total_paid_amount
    invoices.where(status: 'paid').sum(:total_amount)
  end

  def total_unpaid_amount
    invoices.where.not(status: 'paid').sum(:total_amount)
  end

  # Display helpers
  def display_address
    address.presence || "Adresse non renseignée"
  end

  def formatted_siret
    return nil if siret.blank?
    siret.gsub(/(\d{3})(\d{3})(\d{3})(\d{5})/, '\1 \2 \3 \4')
  end

  def professional?
    siret.present?
  end

  private

  def normalize_siret
    return if siret.blank?
    self.siret = siret.gsub(/\s/, '')
  end
end
