# frozen_string_literal: true

require "test_helper"

class AdminMonitoringAuthTest < ActionDispatch::IntegrationTest
  test "whatsapp_messages require authentication" do
    get admin_whatsapp_messages_path
    assert_redirected_to new_admin_session_path
  end

  test "whatsapp_messages show requires authentication" do
    user = users(:active_user)
    msg = WhatsappMessage.create!(
      user: user,
      unipile_message_id: "msg_auth_1",
      direction: "inbound",
      message_type: "text",
      content: "Hello",
      processed: true,
      raw_payload: { any: "thing" }
    )

    get admin_whatsapp_message_path(msg)
    assert_redirected_to new_admin_session_path
  end

  test "llm_conversations require authentication" do
    get admin_llm_conversations_path
    assert_redirected_to new_admin_session_path
  end

  test "llm_conversations show requires authentication" do
    user = users(:active_user)
    conv = LlmConversation.create!(
      user: user,
      messages_payload: [{ role: "user", content: "ping" }],
      response_payload: { content: "pong" },
      tool_name: "create_quote",
      model: "gpt-4",
      total_tokens: 10,
      duration_ms: 1200
    )

    get admin_llm_conversation_path(conv)
    assert_redirected_to new_admin_session_path
  end
end
