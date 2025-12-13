# frozen_string_literal: true

class CreateWhatsappMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :whatsapp_messages do |t|
      t.references :user, null: false, foreign_key: true

      # Unipile identifiers
      t.string :unipile_message_id, null: false
      t.string :unipile_chat_id

      # Message details
      t.string :direction, null: false  # inbound/outbound
      t.string :message_type, default: 'text'  # text/audio/image/document/video
      t.text :content
      t.json :raw_payload

      # Audio processing
      t.text :audio_transcription
      t.string :detected_language

      # Processing status
      t.boolean :processed, default: false
      t.text :error_message
      t.datetime :sent_at

      t.timestamps
    end

    add_index :whatsapp_messages, :unipile_message_id, unique: true
    add_index :whatsapp_messages, :unipile_chat_id
    add_index :whatsapp_messages, [:user_id, :created_at]
    add_index :whatsapp_messages, :processed
  end
end
