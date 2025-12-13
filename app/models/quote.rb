# frozen_string_literal: true

# Quote model (Devis)
# Sequential numbering per user per year - DEVIS-YYYY-NNNN
class Quote < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :client
  has_many :items, class_name: 'QuoteItem', dependent: :destroy
  has_one :invoice, dependent: :nullify

  # Nested attributes for items
  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :quote_number, presence: true, uniqueness: { scope: :user_id }
  validates :issue_date, presence: true
  validates :status, inclusion: { in: %w[draft sent accepted rejected] }
  validates :vat_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # Scopes
  scope :draft, -> { where(status: 'draft') }
  scope :sent, -> { where(status: 'sent') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_date, -> { order(issue_date: :desc) }
  scope :this_year, -> { where("EXTRACT(YEAR FROM issue_date) = ?", Date.current.year) }

  # Callbacks
  before_validation :assign_quote_number, on: :create
  before_save :calculate_totals

  # Status helpers
  def draft?
    status == 'draft'
  end

  def sent?
    status == 'sent'
  end

  def accepted?
    status == 'accepted'
  end

  def rejected?
    status == 'rejected'
  end

  def can_be_edited?
    draft?
  end

  def can_be_sent?
    draft? || sent?
  end

  def can_create_invoice?
    accepted? && invoice.nil?
  end

  # Actions
  def mark_as_sent!
    update!(status: 'sent', sent_via_whatsapp_at: Time.current)
  end

  def mark_as_accepted!
    update!(status: 'accepted')
  end

  def mark_as_rejected!
    update!(status: 'rejected')
  end

  # Display helpers
  def formatted_total
    ActionController::Base.helpers.number_to_currency(total_amount, unit: '€', format: '%n %u')
  end

  def validity_period_days
    return nil unless validity_date && issue_date
    (validity_date - issue_date).to_i
  end

  def expired?
    validity_date.present? && validity_date < Date.current
  end

  private

  # Sequential numbering: DEVIS-YYYY-NNNN (per user, per year)
  def assign_quote_number
    return if quote_number.present?
    return unless user.present?

    year = (issue_date || Date.current).year
    
    # Use database-level query to find the last number
    last_num = user.quotes
                   .where("quote_number LIKE ?", "DEVIS-#{year}-%")
                   .maximum("CAST(SUBSTR(quote_number, -4) AS INTEGER)") || 0

    self.quote_number = "DEVIS-#{year}-#{(last_num + 1).to_s.rjust(4, '0')}"
  end

  def calculate_totals
    self.subtotal_amount = items.sum { |item| item.total_price.to_d }
    self.vat_amount = (subtotal_amount * vat_rate / 100).round(2)
    self.total_amount = subtotal_amount + vat_amount
  end
end
