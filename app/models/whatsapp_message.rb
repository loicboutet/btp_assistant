# frozen_string_literal: true

# WhatsappMessage model - stores all WhatsApp messages (inbound and outbound)
# Uses unipile_message_id for duplicate detection
class WhatsappMessage < ApplicationRecord
  # Associations
  belongs_to :user
  has_one :llm_conversation, dependent: :nullify

  # Validations
  validates :unipile_message_id, presence: true, uniqueness: true
  validates :direction, presence: true, inclusion: { in: %w[inbound outbound] }
  validates :message_type, inclusion: { in: %w[text audio image document video] }

  # Scopes
  scope :inbound, -> { where(direction: 'inbound') }
  scope :outbound, -> { where(direction: 'outbound') }
  scope :text_messages, -> { where(message_type: 'text') }
  scope :audio_messages, -> { where(message_type: 'audio') }
  scope :recent, -> { order(created_at: :desc) }
  scope :unprocessed, -> { where(processed: false) }
  scope :processed, -> { where(processed: true) }
  scope :with_errors, -> { where.not(error_message: nil) }
  scope :within_context_window, ->(hours = 2) { where("created_at > ?", hours.hours.ago) }

  # Direction helpers
  def inbound?
    direction == 'inbound'
  end

  def outbound?
    direction == 'outbound'
  end

  # Type helpers
  def text?
    message_type == 'text'
  end

  def audio?
    message_type == 'audio'
  end

  def image?
    message_type == 'image'
  end

  def document?
    message_type == 'document'
  end

  def video?
    message_type == 'video'
  end

  # Processing helpers
  def mark_as_processed!
    update!(processed: true)
  end

  def mark_as_failed!(error)
    update!(processed: true, error_message: error)
  end

  # Content helpers
  def display_content
    if audio? && audio_transcription.present?
      "🎤 #{audio_transcription}"
    else
      content.presence || "[#{message_type}]"
    end
  end

  def needs_transcription?
    audio? && audio_transcription.blank?
  end

  # Context building for LLM
  def to_llm_message
    role = inbound? ? 'user' : 'assistant'
    text = audio? && audio_transcription.present? ? audio_transcription : content
    
    { role: role, content: text }
  end

  # Class method to check for duplicates before processing
  def self.duplicate?(unipile_message_id)
    exists?(unipile_message_id: unipile_message_id)
  end

  # Get recent context messages for a user
  def self.context_for_user(user, limit: 15, hours: 2)
    user.whatsapp_messages
        .where("created_at > ?", hours.hours.ago)
        .order(created_at: :desc)
        .limit(limit)
        .reverse
  end
end
