# frozen_string_literal: true

# SystemLog model - audit trail and system event logging
class SystemLog < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  belongs_to :admin_user, optional: true, class_name: 'AdminUser', foreign_key: :admin_id

  # Validations
  validates :log_type, presence: true, inclusion: { in: %w[info warning error audit] }
  validates :event, presence: true

  # Scopes
  scope :info, -> { where(log_type: 'info') }
  scope :warnings, -> { where(log_type: 'warning') }
  scope :errors, -> { where(log_type: 'error') }
  scope :audit, -> { where(log_type: 'audit') }
  scope :recent, -> { order(created_at: :desc) }
  scope :today, -> { where("created_at >= ?", Date.current.beginning_of_day) }
  scope :this_week, -> { where("created_at >= ?", 1.week.ago) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_admin, ->(admin_user) { where(admin_id: admin_user.id) }
  scope :by_event, ->(event) { where(event: event) }

  # Log type helpers
  def info?
    log_type == 'info'
  end

  def warning?
    log_type == 'warning'
  end

  def error?
    log_type == 'error'
  end

  def audit?
    log_type == 'audit'
  end

  # Display helpers
  def actor
    admin_user || user
  end

  def actor_name
    if admin_user
      admin_user.email
    elsif user
      user.display_name
    else
      'System'
    end
  end

  def log_type_badge_class
    case log_type
    when 'info' then 'bg-blue-100 text-blue-800'
    when 'warning' then 'bg-yellow-100 text-yellow-800'
    when 'error' then 'bg-red-100 text-red-800'
    when 'audit' then 'bg-purple-100 text-purple-800'
    else 'bg-gray-100 text-gray-800'
    end
  end

  # Factory methods for common log types
  class << self
    def log_info(event, description: nil, metadata: {}, user: nil, admin: nil, admin_user: nil, request: nil)
      create_log('info', event, description, metadata, user, admin || admin_user, request)
    end

    def log_warning(event, description: nil, metadata: {}, user: nil, admin: nil, admin_user: nil, request: nil)
      create_log('warning', event, description, metadata, user, admin || admin_user, request)
    end

    def log_error(event, description: nil, metadata: {}, user: nil, admin: nil, admin_user: nil, request: nil)
      create_log('error', event, description, metadata, user, admin || admin_user, request)
    end

    def log_audit(event, description: nil, metadata: {}, user: nil, admin: nil, admin_user: nil, request: nil)
      create_log('audit', event, description, metadata, user, admin || admin_user, request)
    end

    private

    def create_log(log_type, event, description, metadata, user, admin_user, request)
      create!(
        log_type: log_type,
        event: event,
        description: description,
        metadata: metadata,
        user: user,
        admin_id: admin_user&.id,
        ip_address: request&.remote_ip,
        user_agent: request&.user_agent
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to create system log: #{e.message}"
      nil
    end
  end
end
