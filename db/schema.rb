# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_12_23_095235) do
  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "app_settings", force: :cascade do |t|
    t.string "unipile_account_id"
    t.string "unipile_dsn"
    t.string "unipile_api_key_encrypted"
    t.string "whatsapp_business_number"
    t.string "openai_api_key_encrypted"
    t.string "openai_model", default: "gpt-4"
    t.string "stripe_publishable_key"
    t.string "stripe_secret_key_encrypted"
    t.string "stripe_price_id"
    t.string "stripe_webhook_secret_encrypted"
    t.integer "signed_url_expiration_minutes", default: 30
    t.integer "conversation_context_messages", default: 15
    t.integer "conversation_context_hours", default: 2
    t.integer "rate_limit_messages_per_hour", default: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_trial_days", default: 14
  end

  create_table "clients", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.text "address"
    t.string "siret"
    t.string "contact_phone"
    t.string "contact_email"
    t.string "created_via", default: "whatsapp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_clients_on_user_id_and_name"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "invoice_items", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.text "description", null: false
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0"
    t.string "unit", default: "unité"
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_price", precision: 10, scale: 2, default: "0.0"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id", "position"], name: "index_invoice_items_on_invoice_id_and_position"
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "client_id", null: false
    t.integer "quote_id"
    t.string "invoice_number", null: false
    t.date "issue_date", null: false
    t.date "due_date"
    t.string "status", default: "draft"
    t.decimal "subtotal_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "vat_rate", precision: 5, scale: 2, default: "20.0"
    t.decimal "vat_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.text "notes"
    t.datetime "sent_via_whatsapp_at"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_invoices_on_client_id"
    t.index ["quote_id"], name: "index_invoices_on_quote_id"
    t.index ["status"], name: "index_invoices_on_status"
    t.index ["user_id", "invoice_number"], name: "index_invoices_on_user_id_and_invoice_number", unique: true
    t.index ["user_id", "issue_date"], name: "index_invoices_on_user_id_and_issue_date"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "llm_conversations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "whatsapp_message_id"
    t.json "messages_payload"
    t.json "response_payload"
    t.string "tool_name"
    t.json "tool_arguments"
    t.json "tool_result"
    t.integer "prompt_tokens"
    t.integer "completion_tokens"
    t.integer "total_tokens"
    t.string "model"
    t.integer "duration_ms"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tool_name"], name: "index_llm_conversations_on_tool_name"
    t.index ["user_id", "created_at"], name: "index_llm_conversations_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_llm_conversations_on_user_id"
    t.index ["whatsapp_message_id"], name: "index_llm_conversations_on_whatsapp_message_id"
  end

  create_table "llm_prompts", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.text "prompt_text", null: false
    t.boolean "is_active", default: true
    t.integer "version", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_llm_prompts_on_is_active"
    t.index ["name"], name: "index_llm_prompts_on_name", unique: true
  end

  create_table "quote_items", force: :cascade do |t|
    t.integer "quote_id", null: false
    t.text "description", null: false
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0"
    t.string "unit", default: "unité"
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_price", precision: 10, scale: 2, default: "0.0"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quote_id", "position"], name: "index_quote_items_on_quote_id_and_position"
    t.index ["quote_id"], name: "index_quote_items_on_quote_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "client_id", null: false
    t.string "quote_number", null: false
    t.date "issue_date", null: false
    t.date "validity_date"
    t.string "status", default: "draft"
    t.decimal "subtotal_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "vat_rate", precision: 5, scale: 2, default: "20.0"
    t.decimal "vat_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.text "notes"
    t.datetime "sent_via_whatsapp_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_quotes_on_client_id"
    t.index ["status"], name: "index_quotes_on_status"
    t.index ["user_id", "issue_date"], name: "index_quotes_on_user_id_and_issue_date"
    t.index ["user_id", "quote_number"], name: "index_quotes_on_user_id_and_quote_number", unique: true
    t.index ["user_id"], name: "index_quotes_on_user_id"
  end

  create_table "subscription_invoices", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "subscription_id"
    t.string "stripe_invoice_id", null: false
    t.string "invoice_number"
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency", default: "eur"
    t.string "status"
    t.date "period_start"
    t.date "period_end"
    t.datetime "paid_at"
    t.string "stripe_invoice_url"
    t.string "stripe_invoice_pdf"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_number"], name: "index_subscription_invoices_on_invoice_number"
    t.index ["stripe_invoice_id"], name: "index_subscription_invoices_on_stripe_invoice_id", unique: true
    t.index ["subscription_id"], name: "index_subscription_invoices_on_subscription_id"
    t.index ["user_id"], name: "index_subscription_invoices_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "stripe_subscription_id", null: false
    t.string "stripe_price_id"
    t.string "status", default: "active"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.boolean "cancel_at_period_end", default: false
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "system_logs", force: :cascade do |t|
    t.integer "user_id"
    t.integer "admin_id"
    t.string "log_type", null: false
    t.string "event", null: false
    t.text "description"
    t.json "metadata"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_system_logs_on_admin_id"
    t.index ["created_at"], name: "index_system_logs_on_created_at"
    t.index ["event"], name: "index_system_logs_on_event"
    t.index ["log_type", "created_at"], name: "index_system_logs_on_log_type_and_created_at"
    t.index ["user_id"], name: "index_system_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "phone_number", null: false
    t.string "company_name"
    t.string "siret"
    t.text "address"
    t.string "vat_number"
    t.string "preferred_language", default: "fr"
    t.string "stripe_customer_id"
    t.string "subscription_status", default: "pending"
    t.boolean "onboarding_completed", default: false
    t.datetime "first_message_at"
    t.datetime "last_activity_at"
    t.string "unipile_chat_id"
    t.string "unipile_attendee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.boolean "bypass_subscription", default: false, null: false
    t.datetime "trial_ends_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id"
    t.index ["subscription_status"], name: "index_users_on_subscription_status"
    t.index ["unipile_attendee_id"], name: "index_users_on_unipile_attendee_id"
    t.index ["unipile_chat_id"], name: "index_users_on_unipile_chat_id"
  end

  create_table "whatsapp_messages", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "unipile_message_id", null: false
    t.string "unipile_chat_id"
    t.string "direction", null: false
    t.string "message_type", default: "text"
    t.text "content"
    t.json "raw_payload"
    t.text "audio_transcription"
    t.string "detected_language"
    t.boolean "processed", default: false
    t.text "error_message"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["processed"], name: "index_whatsapp_messages_on_processed"
    t.index ["unipile_chat_id"], name: "index_whatsapp_messages_on_unipile_chat_id"
    t.index ["unipile_message_id"], name: "index_whatsapp_messages_on_unipile_message_id", unique: true
    t.index ["user_id", "created_at"], name: "index_whatsapp_messages_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_whatsapp_messages_on_user_id"
  end

  add_foreign_key "clients", "users"
  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoices", "clients"
  add_foreign_key "invoices", "quotes"
  add_foreign_key "invoices", "users"
  add_foreign_key "llm_conversations", "users"
  add_foreign_key "llm_conversations", "whatsapp_messages"
  add_foreign_key "quote_items", "quotes"
  add_foreign_key "quotes", "clients"
  add_foreign_key "quotes", "users"
  add_foreign_key "subscription_invoices", "subscriptions"
  add_foreign_key "subscription_invoices", "users"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "system_logs", "admins"
  add_foreign_key "system_logs", "users"
  add_foreign_key "whatsapp_messages", "users"
end
