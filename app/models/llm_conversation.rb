# frozen_string_literal: true

# LlmConversation model - logs all LLM interactions
# Useful for debugging, analytics, and monitoring
class LlmConversation < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :whatsapp_message, optional: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :with_tool_calls, -> { where.not(tool_name: nil) }
  scope :with_errors, -> { where.not(error_message: nil) }
  scope :successful, -> { where(error_message: nil) }
  scope :by_tool, ->(tool) { where(tool_name: tool) }
  scope :today, -> { where("created_at >= ?", Date.current.beginning_of_day) }

  # Tool execution helpers
  def tool_called?
    tool_name.present?
  end

  def tool_successful?
    tool_called? && tool_result.present? && !tool_result_error?
  end

  def tool_result_error?
    return false unless tool_result.is_a?(Hash)
    tool_result['success'] == false || tool_result['error'].present?
  end

  # Token helpers
  def total_tokens
    (prompt_tokens || 0) + (completion_tokens || 0)
  end

  # Cost estimation (approximate)
  # GPT-4: ~$0.03 per 1K input tokens, ~$0.06 per 1K output tokens
  def estimated_cost_usd
    return 0 unless prompt_tokens && completion_tokens
    
    input_cost = (prompt_tokens / 1000.0) * 0.03
    output_cost = (completion_tokens / 1000.0) * 0.06
    (input_cost + output_cost).round(4)
  end

  # Duration helpers
  def duration_seconds
    return nil unless duration_ms
    (duration_ms / 1000.0).round(2)
  end

  # Analytics
  def self.tokens_used_today
    today.sum(:total_tokens)
  end

  def self.tool_usage_stats(since: 7.days.ago)
    where("created_at > ?", since)
      .where.not(tool_name: nil)
      .group(:tool_name)
      .count
  end

  def self.average_duration_ms(since: 7.days.ago)
    where("created_at > ?", since)
      .where.not(duration_ms: nil)
      .average(:duration_ms)
      &.round(0)
  end

  def self.error_rate(since: 7.days.ago)
    total = where("created_at > ?", since).count
    return 0 if total.zero?
    
    errors = where("created_at > ?", since).with_errors.count
    ((errors.to_f / total) * 100).round(2)
  end
end
