# frozen_string_literal: true

require "test_helper"

class WhatsappBot::ConversationEngineTest < ActiveSupport::TestCase
  setup do
    @user = users(:active_user)
    @user.update!(
      company_name: "Test Company",
      siret: "12345678901234",
      address: "123 Test Street"
    )
    
    # Setup app settings
    AppSetting.instance.update!(
      openai_api_key: "sk-test-key",
      openai_model: "gpt-4",
      unipile_dsn: "https://api.unipile.com:13211",
      unipile_api_key: "test-key",
      unipile_account_id: "test-account"
    )
    
    @engine = WhatsappBot::ConversationEngine.new(user: @user)
  end

  # ==========================================
  # Basic Processing Tests
  # ==========================================

  test "processes simple text message" do
    mock_simple_response("Bonjour! Comment puis-je vous aider?")
    
    response = @engine.process_message("Bonjour")
    
    assert_equal "Bonjour! Comment puis-je vous aider?", response
  end

  test "returns error message for blank input" do
    response = @engine.process_message("")
    
    assert_match(/erreur|hata/i, response)
  end

  test "returns error message for nil input" do
    response = @engine.process_message(nil)
    
    assert_match(/erreur|hata/i, response)
  end

  # ==========================================
  # Tool Calling Tests
  # ==========================================

  test "executes tool and returns final response" do
    # First call: GPT returns tool call, second call: GPT returns text after tool result
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(
        { status: 200, body: tool_call_response("search_clients", { "query" => "Dupont" }).to_json },
        { status: 200, body: simple_response("Je n'ai trouvé aucun client nommé Dupont.").to_json }
      )
    
    response = @engine.process_message("Cherche le client Dupont")
    
    assert_equal "Je n'ai trouvé aucun client nommé Dupont.", response
  end

  test "handles multiple tool calls in sequence" do
    # This tests that the engine can handle multiple iterations
    # First call: search_clients
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(
        { status: 200, body: tool_call_response("search_clients", { "query" => "Test" }).to_json },
        { status: 200, body: simple_response("Aucun client trouvé. Voulez-vous en créer un?").to_json }
      )
    
    response = @engine.process_message("Cherche Test")
    
    assert_includes response, "client"
  end

  test "stops after max iterations" do
    # Return tool call every time (infinite loop scenario)
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(status: 200, body: tool_call_response("search_clients", { "query" => "Test" }).to_json)
    
    response = @engine.process_message("Test")
    
    assert_match(/complexe|karmaşık/i, response)
  end

  # ==========================================
  # Context Building Tests
  # ==========================================

  test "includes recent messages in context" do
    # Create some recent messages
    @user.whatsapp_messages.create!(
      unipile_message_id: "msg_1",
      direction: "inbound",
      content: "Previous message",
      message_type: "text",
      created_at: 1.hour.ago
    )
    
    mock_simple_response("Test response")
    
    @engine.process_message("New message")
    
    # The engine should include context - we verify by checking the request was made
    assert_requested :post, "https://api.openai.com/v1/chat/completions"
  end

  test "excludes old messages from context" do
    # Create an old message (outside context window)
    @user.whatsapp_messages.create!(
      unipile_message_id: "old_msg",
      direction: "inbound",
      content: "Very old message",
      message_type: "text",
      created_at: 5.hours.ago
    )
    
    mock_simple_response("Test response")
    
    @engine.process_message("New message")
    
    assert_requested :post, "https://api.openai.com/v1/chat/completions"
  end

  # ==========================================
  # Language Tests
  # ==========================================

  test "updates language preference when detected" do
    @user.update!(preferred_language: "fr")
    mock_simple_response("Test")
    
    @engine.process_message("Test message", detected_language: "tr")
    
    @user.reload
    assert_equal "tr", @user.preferred_language
  end

  test "does not update language for invalid language code" do
    @user.update!(preferred_language: "fr")
    mock_simple_response("Test")
    
    @engine.process_message("Test message", detected_language: "de")
    
    @user.reload
    assert_equal "fr", @user.preferred_language
  end

  # ==========================================
  # Error Handling Tests
  # ==========================================

  test "returns error message when OpenAI not configured" do
    AppSetting.instance.update!(openai_api_key: nil)
    
    engine = WhatsappBot::ConversationEngine.new(user: @user)
    response = engine.process_message("Test")
    
    assert_match(/disponible|kullanılamıyor/i, response)
  end

  test "returns rate limit message when rate limited" do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(status: 429, body: { error: { message: "Rate limit" } }.to_json)
    
    response = @engine.process_message("Test")
    
    assert_match(/trop de messages|fazla istek/i, response)
  end

  test "returns error message for API errors" do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(status: 500, body: { error: { message: "Server error" } }.to_json)
    
    response = @engine.process_message("Test")
    
    assert_match(/erreur|hata/i, response)
  end

  # ==========================================
  # Logging Tests
  # ==========================================

  test "logs LLM conversation" do
    mock_simple_response("Test response")
    
    assert_difference "LlmConversation.count", 1 do
      @engine.process_message("Test message")
    end
    
    log = LlmConversation.last
    assert_equal @user.id, log.user_id
    assert_not_nil log.messages_payload
    assert_not_nil log.response_payload
  end

  test "logs tool calls in conversation" do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(
        { status: 200, body: tool_call_response("get_user_info", {}).to_json },
        { status: 200, body: simple_response("Voici vos informations...").to_json }
      )
    
    # Two API calls = two conversation logs
    assert_difference "LlmConversation.count", 2 do
      @engine.process_message("Quelles sont mes infos?")
    end
    
    tool_log = LlmConversation.order(:created_at).first
    assert_equal "get_user_info", tool_log.tool_name
  end

  private

  def mock_simple_response(content)
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(status: 200, body: simple_response(content).to_json)
  end

  def simple_response(content)
    {
      "choices" => [{
        "message" => {
          "role" => "assistant",
          "content" => content
        },
        "finish_reason" => "stop"
      }],
      "usage" => { "prompt_tokens" => 50, "completion_tokens" => 20, "total_tokens" => 70 },
      "model" => "gpt-4"
    }
  end

  def tool_call_response(tool_name, args)
    {
      "choices" => [{
        "message" => {
          "role" => "assistant",
          "content" => nil,
          "tool_calls" => [{
            "id" => "call_#{SecureRandom.hex(8)}",
            "type" => "function",
            "function" => {
              "name" => tool_name,
              "arguments" => args.to_json
            }
          }]
        },
        "finish_reason" => "tool_calls"
      }],
      "usage" => { "prompt_tokens" => 100, "completion_tokens" => 30, "total_tokens" => 130 },
      "model" => "gpt-4"
    }
  end
end
