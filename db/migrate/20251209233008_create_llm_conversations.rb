# frozen_string_literal: true

class CreateLlmConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :llm_conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :whatsapp_message, foreign_key: true

      # Request/Response payloads
      t.json :messages_payload
      t.json :response_payload

      # Tool execution
      t.string :tool_name
      t.json :tool_arguments
      t.json :tool_result

      # Metrics
      t.integer :prompt_tokens
      t.integer :completion_tokens
      t.integer :total_tokens
      t.string :model
      t.integer :duration_ms

      # Error tracking
      t.text :error_message

      t.timestamps
    end

    add_index :llm_conversations, [:user_id, :created_at]
    add_index :llm_conversations, :tool_name
  end
end
