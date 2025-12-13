# frozen_string_literal: true

# SubscriptionInvoice model - tracks Stripe invoices for subscriptions
# These are the invoices for the BTP Assistant service, not client invoices
class SubscriptionInvoice < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :subscription, optional: true

  # Validations
  validates :stripe_invoice_id, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[draft open paid uncollectible void] }

  # Scopes
  scope :paid, -> { where(status: 'paid') }
  scope :unpaid, -> { where(status: %w[draft open]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :this_year, -> { where("EXTRACT(YEAR FROM period_start) = ?", Date.current.year) }

  # Status helpers
  def paid?
    status == 'paid'
  end

  def unpaid?
    status.in?(%w[draft open])
  end

  def void?
    status == 'void'
  end

  # Display helpers
  def formatted_amount
    ActionController::Base.helpers.number_to_currency(amount, unit: '€', format: '%n %u')
  end

  def period_description
    return nil unless period_start && period_end
    
    if period_start.month == period_end.month
      I18n.l(period_start, format: '%B %Y')
    else
      "#{I18n.l(period_start, format: '%B')} - #{I18n.l(period_end, format: '%B %Y')}"
    end
  end

  # Create or update from Stripe webhook
  def self.create_or_update_from_stripe(stripe_invoice, user)
    invoice = find_or_initialize_by(stripe_invoice_id: stripe_invoice.id)
    
    invoice.assign_attributes(
      user: user,
      invoice_number: stripe_invoice.number,
      amount: stripe_invoice.amount_paid / 100.0,
      currency: stripe_invoice.currency,
      status: stripe_invoice.status,
      period_start: stripe_invoice.period_start ? Date.at(stripe_invoice.period_start) : nil,
      period_end: stripe_invoice.period_end ? Date.at(stripe_invoice.period_end) : nil,
      paid_at: stripe_invoice.status_transitions&.paid_at ? Time.at(stripe_invoice.status_transitions.paid_at) : nil,
      stripe_invoice_url: stripe_invoice.hosted_invoice_url,
      stripe_invoice_pdf: stripe_invoice.invoice_pdf
    )

    # Find subscription if present
    if stripe_invoice.subscription.present?
      subscription = Subscription.find_by(stripe_subscription_id: stripe_invoice.subscription)
      invoice.subscription = subscription
    end

    invoice.save!
    invoice
  end
end
