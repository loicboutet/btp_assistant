# frozen_string_literal: true

require "test_helper"

class AdminMonitoringTest < AdminRequestTestCase
  test "whatsapp_messages index works" do
    sign_in_admin

    user = users(:active_user)
    WhatsappMessage.create!(
      user: user,
      unipile_message_id: "msg_1",
      direction: "inbound",
      message_type: "text",
      content: "Bonjour",
      processed: true,
      raw_payload: { any: "thing" }
    )

    get admin_whatsapp_messages_path
    assert_response :success
    assert_match "Messages WhatsApp", response.body
    # La vue affiche le contenu (pas forcément l'unipile_message_id)
    assert_match "Bonjour", response.body
    assert_match user.display_name, response.body
  end

  test "whatsapp_messages search works" do
    sign_in_admin

    user = users(:active_user)
    WhatsappMessage.create!(
      user: user,
      unipile_message_id: "msg_search_hit",
      direction: "inbound",
      message_type: "text",
      content: "Texte très spécifique",
      processed: true,
      raw_payload: { any: "thing" }
    )
    WhatsappMessage.create!(
      user: user,
      unipile_message_id: "msg_search_miss",
      direction: "inbound",
      message_type: "text",
      content: "Autre contenu",
      processed: true,
      raw_payload: { any: "thing" }
    )

    get admin_whatsapp_messages_path, params: { q: "spécifique" }
    assert_response :success

    assert_match "Texte très spécifique", response.body
    refute_match "msg_search_miss", response.body
  end

  test "whatsapp_messages show works" do
    sign_in_admin

    user = users(:active_user)
    msg = WhatsappMessage.create!(
      user: user,
      unipile_message_id: "msg_show",
      direction: "inbound",
      message_type: "text",
      content: "Hello show",
      processed: true,
      raw_payload: { any: "thing" }
    )

    get admin_whatsapp_message_path(msg)
    assert_response :success
    assert_match "Hello show", response.body
    assert_match "msg_show", response.body
  end

  test "llm_conversations index works" do
    sign_in_admin

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

    get admin_llm_conversations_path
    assert_response :success
    assert_match "Conversations LLM", response.body
    assert_match "create_quote", response.body

    get admin_llm_conversation_path(conv)
    assert_response :success
  end
end
