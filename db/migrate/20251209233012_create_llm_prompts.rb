# frozen_string_literal: true

class CreateLlmPrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :llm_prompts do |t|
      t.string :name, null: false
      t.string :description
      t.text :prompt_text, null: false
      t.boolean :is_active, default: true
      t.integer :version, default: 1

      t.timestamps
    end

    add_index :llm_prompts, :name, unique: true
    add_index :llm_prompts, :is_active
  end
end
