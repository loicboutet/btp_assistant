# frozen_string_literal: true

require "test_helper"

class UnipileWebhookFlowTest < ActionDispatch::IntegrationTest
  include ExternalApiStubs

  setup do
    @settings = AppSetting.instance
    @settings.update!(
      unipile_account_id: "test_account_123",
      unipile_dsn: "https://api.test.unipile.com",
      unipile_api_key: "test_key"
    )

    @user = users(:active_user)
  end

  test "webhook Unipile -> crée WhatsappMessage et enqueue ProcessWhatsappMessageJob" do
    payload = {
      "event" => "message_received",
      "account_id" => "test_account_123",
      "chat_id" => "chat_789",
      "message_id" => "msg_e2e_123",
      "message" => "Bonjour!",
      "timestamp" => Time.current.iso8601,
      "sender" => {
        "attendee_id" => "att_123",
        "attendee_name" => "Test User",
        "attendee_provider_id" => @user.phone_number
      }
    }

    before_jobs = enqueued_jobs.size

    assert_difference("WhatsappMessage.count", 1) do
      post webhooks_unipile_messages_url, params: payload, as: :json
    end

    assert_response :ok

    message = WhatsappMessage.order(:id).last
    assert_equal @user.id, message.user_id
    assert_equal "msg_e2e_123", message.unipile_message_id
    assert_equal "text", message.message_type

    assert_equal before_jobs + 1, enqueued_jobs.size
    job = enqueued_jobs.last
    assert_equal ProcessWhatsappMessageJob, job[:job]
    assert_equal [message.id], job[:args]
  end
end
