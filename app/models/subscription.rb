# frozen_string_literal: true

# Subscription model - tracks Stripe subscription status
class Subscription < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :subscription_invoices, dependent: :nullify

  # Validations
  validates :stripe_subscription_id, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[active past_due canceled unpaid incomplete] }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :past_due, -> { where(status: 'past_due') }
  scope :canceled, -> { where(status: 'canceled') }
  scope :expiring_soon, -> { active.where('current_period_end <= ?', 7.days.from_now) }

  # Callbacks
  # Keep user.subscription_status in sync.
  # Note: on create, if status == DB default, Rails may not mark it as changed,
  # so we sync on every save (only writes when different).
  after_save :sync_user_status

  # Status helpers
  def active?
    status == 'active'
  end

  def past_due?
    status == 'past_due'
  end

  def canceled?
    status == 'canceled'
  end

  def will_cancel?
    cancel_at_period_end?
  end

  # Period helpers
  def days_remaining
    return nil unless current_period_end
    [(current_period_end.to_date - Date.current).to_i, 0].max
  end

  def renewal_date
    return nil if cancel_at_period_end?
    current_period_end
  end

  def cancellation_date
    return nil unless cancel_at_period_end?
    current_period_end
  end

  # Update from Stripe webhook
  def update_from_stripe(stripe_sub)
    update!(
      status: stripe_sub.status,
      current_period_start: Time.at(stripe_sub.current_period_start),
      current_period_end: Time.at(stripe_sub.current_period_end),
      cancel_at_period_end: stripe_sub.cancel_at_period_end,
      canceled_at: stripe_sub.canceled_at ? Time.at(stripe_sub.canceled_at) : nil
    )
  end

  private

  # Sync user's subscription_status with this subscription
  def sync_user_status
    return if status.blank?

    new_status = case status
                 when 'active' then 'active'
                 when 'past_due' then 'past_due'
                 when 'canceled', 'unpaid' then 'canceled'
                 else user.subscription_status
                 end

    user.update_column(:subscription_status, new_status) if user.subscription_status != new_status
  end
end
