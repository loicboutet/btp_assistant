# frozen_string_literal: true

require "test_helper"

class Webhooks::Unipile::MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Configure AppSetting with test account ID
    @settings = AppSetting.instance
    @settings.update!(
      unipile_account_id: "test_account_123",
      unipile_dsn: "https://api.test.unipile.com",
      unipile_api_key: "test_key",
      # Prevent controller from trying to auto-fetch account info (HTTP) during tests
      whatsapp_business_number: "+33999999999"
    )

    # Create a test user with unique phone number
    @existing_user = User.create!(
      phone_number: "+33677112233",
      company_name: "Test Company Webhook",
      subscription_status: "active"
    )
  end

  # ==========================================
  # Valid Webhook Tests
  # ==========================================

  test "creates message and user for new phone number" do
    payload = build_webhook_payload(
      phone: "+33699999999",
      message: "Bonjour!",
      message_id: "msg_new_user_123"
    )

    assert_difference -> { User.count } => 1, -> { WhatsappMessage.count } => 1 do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok

    # Verify user was created
    new_user = User.find_by(phone_number: "+33699999999")
    assert_not_nil new_user
    assert_equal "pending", new_user.subscription_status
    assert_not_nil new_user.first_message_at

    # Verify message was created
    message = WhatsappMessage.last
    assert_equal new_user.id, message.user_id
    assert_equal "msg_new_user_123", message.unipile_message_id
    assert_equal "Bonjour!", message.content
    assert_equal "text", message.message_type
    assert_equal "inbound", message.direction
    assert_not message.processed?
  end

  test "creates message for existing user" do
    payload = build_webhook_payload(
      phone: "+33677112233",
      message: "Comment ça va?",
      message_id: "msg_existing_user_456"
    )

    assert_difference -> { User.count } => 0, -> { WhatsappMessage.count } => 1 do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok

    message = WhatsappMessage.last
    assert_equal @existing_user.id, message.user_id
  end

  test "updates user activity timestamp" do
    old_activity = 1.day.ago
    @existing_user.update!(last_activity_at: old_activity)

    payload = build_webhook_payload(
      phone: "+33677112233",
      message: "Test",
      message_id: "msg_activity_test"
    )

    post webhooks_unipile_messages_url, params: payload, as: :json

    @existing_user.reload
    assert @existing_user.last_activity_at > old_activity
  end

  test "queues ProcessWhatsappMessageJob" do
    payload = build_webhook_payload(
      phone: "+33677112233",
      message: "Test job",
      message_id: "msg_job_test"
    )

    assert_enqueued_with(job: ProcessWhatsappMessageJob) do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end
  end

  # ==========================================
  # Audio Message Tests
  # ==========================================

  test "handles audio message type" do
    payload = build_webhook_payload(
      phone: "+33677112233",
      message: "",
      message_id: "msg_audio_123",
      attachments: { "type" => "audio", "id" => "att_audio_456" }
    )

    post webhooks_unipile_messages_url, params: payload, as: :json

    assert_response :ok

    message = WhatsappMessage.last
    assert_equal "audio", message.message_type
    assert message.needs_transcription?
  end

  test "handles image message type" do
    payload = build_webhook_payload(
      phone: "+33677112233",
      message: "",
      message_id: "msg_image_123",
      attachments: { "type" => "image", "id" => "att_img_456" }
    )

    post webhooks_unipile_messages_url, params: payload, as: :json

    assert_response :ok

    message = WhatsappMessage.last
    assert_equal "image", message.message_type
  end

  # ==========================================
  # Duplicate Prevention Tests
  # ==========================================

  test "ignores duplicate messages" do
    # Create existing message
    WhatsappMessage.create!(
      user: @existing_user,
      unipile_message_id: "msg_duplicate_123",
      unipile_chat_id: "chat_456",
      direction: "inbound",
      message_type: "text",
      content: "Original message"
    )

    payload = build_webhook_payload(
      phone: "+33677112233",
      message: "Duplicate attempt",
      message_id: "msg_duplicate_123"
    )

    assert_no_difference "WhatsappMessage.count" do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok
  end

  # ==========================================
  # Account Validation Tests
  # ==========================================

  test "ignores webhook with wrong account_id (ack 200 to avoid Unipile retries)" do
    payload = build_webhook_payload(
      phone: "+33677112233",
      message: "Test",
      message_id: "msg_wrong_account",
      account_id: "wrong_account_id"
    )

    assert_no_difference "WhatsappMessage.count" do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok
  end

  test "accepts webhook when account_id not configured" do
    @settings.update!(unipile_account_id: nil)

    payload = build_webhook_payload(
      phone: "+33677112233",
      message: "Test",
      message_id: "msg_no_account_config",
      account_id: "any_account"
    )

    assert_difference "WhatsappMessage.count", 1 do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok
  end

  # ==========================================
  # Event Type Tests
  # ==========================================

  test "ignores message_reaction events" do
    payload = build_webhook_payload(
      phone: "+33677112233",
      message: "Test",
      message_id: "msg_reaction_test"
    ).merge("event" => "message_reaction")

    assert_no_difference "WhatsappMessage.count" do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok
  end

  test "ignores message_read events" do
    payload = build_webhook_payload(
      phone: "+33677112233",
      message: "Test",
      message_id: "msg_read_test"
    ).merge("event" => "message_read")

    assert_no_difference "WhatsappMessage.count" do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok
  end

  # ==========================================
  # Self-Sent Message Detection (Anti-Loop) Tests
  # ==========================================

  test "ignores messages from sender named 'You'" do
    # When Unipile echoes back our own sent messages, sender.attendee_name is "You"
    payload = {
      "event" => "message_received",
      "account_id" => "test_account_123",
      "chat_id" => "chat_789",
      "message_id" => "msg_self_you",
      "message" => "This is a bot response that should be ignored",
      "timestamp" => Time.current.iso8601,
      "sender" => {
        "attendee_id" => "att_bot",
        "attendee_name" => "You",
        "attendee_provider_id" => "33769363669@s.whatsapp.net"
      },
      "attendees" => [
        {
          "attendee_id" => "att_user",
          "attendee_name" => "Some User",
          "attendee_provider_id" => "33749368028@s.whatsapp.net"
        }
      ]
    }

    assert_no_difference "WhatsappMessage.count" do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok
  end

  test "ignores messages from sender named 'Vous' (French)" do
    payload = {
      "event" => "message_received",
      "account_id" => "test_account_123",
      "chat_id" => "chat_789",
      "message_id" => "msg_self_vous",
      "message" => "Bot response in French locale",
      "timestamp" => Time.current.iso8601,
      "sender" => {
        "attendee_id" => "att_bot",
        "attendee_name" => "Vous",
        "attendee_provider_id" => "33769363669@s.whatsapp.net"
      }
    }

    assert_no_difference "WhatsappMessage.count" do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok
  end

  test "ignores messages where sender matches whatsapp_business_number" do
    @settings.update!(whatsapp_business_number: "+33769363669")

    payload = {
      "event" => "message_received",
      "account_id" => "test_account_123",
      "chat_id" => "chat_789",
      "message_id" => "msg_self_business",
      "message" => "Message from business number",
      "timestamp" => Time.current.iso8601,
      "sender" => {
        "attendee_id" => "att_bot",
        "attendee_name" => "BTP Assistant",
        "attendee_provider_id" => "33769363669@s.whatsapp.net"
      }
    }

    assert_no_difference "WhatsappMessage.count" do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok
  end

  test "processes legitimate inbound messages (sender is not You)" do
    # Real inbound message from a user to the bot
    payload = {
      "event" => "message_received",
      "account_id" => "test_account_123",
      "chat_id" => "chat_789",
      "message_id" => "msg_real_inbound",
      "message" => "Je veux créer un devis",
      "timestamp" => Time.current.iso8601,
      "sender" => {
        "attendee_id" => "att_user",
        "attendee_name" => "5000.dev",
        "attendee_provider_id" => "33749368028@s.whatsapp.net"
      },
      "attendees" => [
        {
          "attendee_id" => "att_user",
          "attendee_name" => "5000.dev",
          "attendee_provider_id" => "33749368028@s.whatsapp.net"
        }
      ]
    }

    assert_difference "WhatsappMessage.count", 1 do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok
    
    # Verify the user was created/found with the sender's phone
    user = User.find_by(phone_number: "+33749368028")
    assert_not_nil user
  end

  test "ignores messages sent by registered user to another contact" do
    # Create the user who owns the WhatsApp account
    bot_user = User.create!(
      phone_number: "+33769363669",
      company_name: "Mel Agari",
      subscription_status: "active"
    )

    # When the bot sends a message, sender is the registered user
    # but attendees contains the recipient (external contact)
    payload = {
      "event" => "message_received",
      "account_id" => "test_account_123",
      "chat_id" => "chat_789",
      "message_id" => "msg_bot_to_contact",
      "message" => "Voici votre devis",
      "timestamp" => Time.current.iso8601,
      "sender" => {
        "attendee_id" => "att_bot",
        "attendee_name" => "Mel Agari",
        "attendee_provider_id" => "33769363669@s.whatsapp.net"
      },
      "attendees" => [
        {
          "attendee_id" => "att_external",
          "attendee_name" => "Client Externe",
          "attendee_provider_id" => "33612345678@s.whatsapp.net"
        }
      ]
    }

    assert_no_difference "WhatsappMessage.count" do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok
  end

  # ==========================================
  # Phone Number Extraction Tests
  # ==========================================

  test "extracts phone from WhatsApp format" do
    payload = {
      "event" => "message_received",
      "account_id" => "test_account_123",
      "chat_id" => "chat_789",
      "message_id" => "msg_wa_format",
      "message" => "Test",
      "sender" => {
        "attendee_id" => "att_123",
        "attendee_name" => "Test User",
        "attendee_provider_id" => "33687654321@s.whatsapp.net"
      }
    }

    post webhooks_unipile_messages_url, params: payload, as: :json

    assert_response :ok
    user = User.find_by(phone_number: "+33687654321")
    assert_not_nil user
  end

  test "extracts phone from attendee identifier" do
    payload = {
      "event" => "message_received",
      "account_id" => "test_account_123",
      "chat_id" => "chat_789",
      "message_id" => "msg_identifier_format",
      "message" => "Test",
      "data" => {
        "attendee" => {
          "identifier" => "+33688776655"
        }
      },
      "sender" => {
        "attendee_name" => "Test User"
      }
    }

    post webhooks_unipile_messages_url, params: payload, as: :json

    assert_response :ok
    user = User.find_by(phone_number: "+33688776655")
    assert_not_nil user
  end

  # ==========================================
  # Unipile Info Update Tests
  # ==========================================

  test "updates user unipile_chat_id" do
    @existing_user.update!(unipile_chat_id: nil)

    payload = build_webhook_payload(
      phone: "+33677112233",
      message: "Test",
      message_id: "msg_chat_update",
      chat_id: "new_chat_id_123"
    )

    post webhooks_unipile_messages_url, params: payload, as: :json

    @existing_user.reload
    assert_equal "new_chat_id_123", @existing_user.unipile_chat_id
  end

  # ==========================================
  # System Log Tests
  # ==========================================

  test "creates system log for received message" do
    payload = build_webhook_payload(
      phone: "+33677112233",
      message: "Test logging",
      message_id: "msg_log_test"
    )

    assert_difference "SystemLog.where(event: 'whatsapp_message_received').count", 1 do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    log = SystemLog.where(event: "whatsapp_message_received").last
    assert_equal "info", log.log_type
    assert_equal @existing_user.id, log.user_id
  end

  # ==========================================
  # Error Handling Tests
  # ==========================================

  test "returns unprocessable_entity when phone extraction fails" do
    payload = {
      "event" => "message_received",
      "account_id" => "test_account_123",
      "message_id" => "msg_no_phone",
      "message" => "Test",
      "sender" => {
        "attendee_name" => "Unknown"
      }
    }

    post webhooks_unipile_messages_url, params: payload, as: :json

    assert_response :unprocessable_entity
  end

  private

  def build_webhook_payload(phone:, message:, message_id:, account_id: "test_account_123", chat_id: "chat_456", attachments: nil)
    payload = {
      "event" => "message_received",
      "account_id" => account_id,
      "chat_id" => chat_id,
      "message_id" => message_id,
      "message" => message,
      "timestamp" => Time.current.iso8601,
      "sender" => {
        "attendee_id" => "att_#{SecureRandom.hex(4)}",
        "attendee_name" => "Test User",
        "attendee_provider_id" => phone
      }
    }

    payload["attachments"] = attachments if attachments.present?
    payload
  end
end
