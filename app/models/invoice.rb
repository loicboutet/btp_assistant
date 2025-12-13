# frozen_string_literal: true

# Invoice model (Facture)
# Sequential numbering per user per year - FACT-YYYY-NNNN
class Invoice < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :client
  belongs_to :quote, optional: true
  has_many :items, class_name: 'InvoiceItem', dependent: :destroy

  # Nested attributes for items
  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :invoice_number, presence: true, uniqueness: { scope: :user_id }
  validates :issue_date, presence: true
  validates :status, inclusion: { in: %w[draft sent paid overdue canceled] }
  validates :vat_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # Scopes
  scope :draft, -> { where(status: 'draft') }
  scope :sent, -> { where(status: 'sent') }
  scope :paid, -> { where(status: 'paid') }
  scope :overdue, -> { where(status: 'overdue') }
  scope :canceled, -> { where(status: 'canceled') }
  scope :unpaid, -> { where(status: %w[sent overdue]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_date, -> { order(issue_date: :desc) }
  scope :this_year, -> { where("EXTRACT(YEAR FROM issue_date) = ?", Date.current.year) }
  scope :due_soon, -> { unpaid.where("due_date <= ?", 7.days.from_now) }

  # Callbacks
  before_validation :assign_invoice_number, on: :create
  before_save :calculate_totals
  after_save :update_overdue_status

  # Status helpers
  def draft?
    status == 'draft'
  end

  def sent?
    status == 'sent'
  end

  def paid?
    status == 'paid'
  end

  def overdue?
    status == 'overdue'
  end

  def canceled?
    status == 'canceled'
  end

  def unpaid?
    sent? || overdue?
  end

  def can_be_edited?
    draft?
  end

  def can_be_sent?
    draft? || sent?
  end

  def can_be_paid?
    sent? || overdue?
  end

  # Actions
  def mark_as_sent!
    update!(status: 'sent', sent_via_whatsapp_at: Time.current)
  end

  def mark_as_paid!(payment_date = Time.current)
    update!(status: 'paid', paid_at: payment_date)
  end

  def mark_as_canceled!
    update!(status: 'canceled')
  end

  # Create invoice from quote
  def self.create_from_quote(quote)
    invoice = new(
      user: quote.user,
      client: quote.client,
      quote: quote,
      issue_date: Date.current,
      due_date: 30.days.from_now.to_date,
      vat_rate: quote.vat_rate,
      notes: quote.notes
    )

    quote.items.each do |quote_item|
      invoice.items.build(
        description: quote_item.description,
        quantity: quote_item.quantity,
        unit: quote_item.unit,
        unit_price: quote_item.unit_price
      )
    end

    invoice
  end

  # Display helpers
  def formatted_total
    ActionController::Base.helpers.number_to_currency(total_amount, unit: '€', format: '%n %u')
  end

  def days_until_due
    return nil unless due_date
    (due_date - Date.current).to_i
  end

  def days_overdue
    return 0 unless due_date && due_date < Date.current
    (Date.current - due_date).to_i
  end

  private

  # Sequential numbering: FACT-YYYY-NNNN (per user, per year)
  def assign_invoice_number
    return if invoice_number.present?
    return unless user.present?

    year = (issue_date || Date.current).year
    
    # Use database-level query to find the last number
    last_num = user.invoices
                   .where("invoice_number LIKE ?", "FACT-#{year}-%")
                   .maximum("CAST(SUBSTR(invoice_number, -4) AS INTEGER)") || 0

    self.invoice_number = "FACT-#{year}-#{(last_num + 1).to_s.rjust(4, '0')}"
  end

  def calculate_totals
    self.subtotal_amount = items.sum { |item| item.total_price.to_d }
    self.vat_amount = (subtotal_amount * vat_rate / 100).round(2)
    self.total_amount = subtotal_amount + vat_amount
  end

  def update_overdue_status
    return unless saved_change_to_status? || saved_change_to_due_date?
    return unless sent? && due_date.present? && due_date < Date.current

    update_column(:status, 'overdue')
  end
end
