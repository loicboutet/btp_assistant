# frozen_string_literal: true

require "test_helper"

class UnipileClientTest < ActiveSupport::TestCase
  setup do
    # Configure AppSetting with test values
    @settings = AppSetting.instance
    @settings.update!(
      unipile_dsn: "https://api.test.unipile.com",
      unipile_api_key: "test_api_key_123",
      unipile_account_id: "test_account_id_456"
    )

    @client = UnipileClient.new
  end

  # ==========================================
  # Configuration Tests
  # ==========================================

  test "initializes with settings from AppSetting" do
    assert_not_nil @client
  end

  test "accepts custom configuration" do
    custom_client = UnipileClient.new(
      dsn: "https://custom.unipile.com",
      api_key: "custom_key",
      account_id: "custom_account"
    )
    assert_not_nil custom_client
  end

  test "raises ConfigurationError when dsn is missing" do
    @settings.update!(unipile_dsn: nil)

    assert_raises(UnipileClient::ConfigurationError) do
      UnipileClient.new
    end
  end

  test "raises ConfigurationError when api_key is missing" do
    @settings.update!(unipile_api_key: nil)

    assert_raises(UnipileClient::ConfigurationError) do
      UnipileClient.new
    end
  end

  test "raises ConfigurationError when account_id is missing" do
    @settings.update!(unipile_account_id: nil)

    assert_raises(UnipileClient::ConfigurationError) do
      UnipileClient.new
    end
  end

  # ==========================================
  # send_message Tests
  # ==========================================

  test "send_message sends text to chat" do
    stub_request(:post, "https://api.test.unipile.com/api/v1/chats/chat_123/messages")
      .with(
        headers: { 'X-API-KEY' => 'test_api_key_123' }
      )
      .to_return(
        status: 200,
        body: { message_id: "msg_789", timestamp: "2025-01-01T12:00:00Z" }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    result = @client.send_message(chat_id: "chat_123", text: "Hello!")

    assert_equal "msg_789", result["message_id"]
  end

  test "send_message raises Error when chat_id is blank" do
    assert_raises(UnipileClient::Error) do
      @client.send_message(chat_id: "", text: "Hello!")
    end
  end

  test "send_message raises Error when text is blank" do
    assert_raises(UnipileClient::Error) do
      @client.send_message(chat_id: "chat_123", text: "")
    end
  end

  # ==========================================
  # get_account_info Tests
  # ==========================================

  test "get_account_info returns account details" do
    stub_request(:get, "https://api.test.unipile.com/api/v1/accounts/test_account_id_456")
      .with(headers: { 'X-API-KEY' => 'test_api_key_123' })
      .to_return(
        status: 200,
        body: {
          id: "test_account_id_456",
          provider: "WHATSAPP",
          connection: { phone_number: "+33612345678" }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    result = @client.get_account_info

    assert_equal "test_account_id_456", result["id"]
    assert_equal "WHATSAPP", result["provider"]
    assert_equal "+33612345678", result.dig("connection", "phone_number")
  end

  test "get_account_info raises AuthenticationError on 401" do
    stub_request(:get, "https://api.test.unipile.com/api/v1/accounts/test_account_id_456")
      .to_return(status: 401, body: { error: "Unauthorized" }.to_json)

    assert_raises(UnipileClient::AuthenticationError) do
      @client.get_account_info
    end
  end

  test "get_account_info raises NotFoundError on 404" do
    stub_request(:get, "https://api.test.unipile.com/api/v1/accounts/test_account_id_456")
      .to_return(status: 404, body: { error: "Not found" }.to_json)

    assert_raises(UnipileClient::NotFoundError) do
      @client.get_account_info
    end
  end

  test "get_account_info raises RateLimitError on 429" do
    stub_request(:get, "https://api.test.unipile.com/api/v1/accounts/test_account_id_456")
      .to_return(status: 429, body: { error: "Rate limit exceeded" }.to_json)

    assert_raises(UnipileClient::RateLimitError) do
      @client.get_account_info
    end
  end

  # ==========================================
  # download_attachment Tests
  # ==========================================

  test "download_attachment returns content and metadata" do
    audio_content = "fake audio binary content"

    stub_request(:get, "https://api.test.unipile.com/api/v1/attachments/att_123")
      .with(headers: { 'X-API-KEY' => 'test_api_key_123' })
      .to_return(
        status: 200,
        body: audio_content,
        headers: {
          'Content-Type' => 'audio/ogg',
          'Content-Disposition' => 'attachment; filename="voice_message.ogg"'
        }
      )

    result = @client.download_attachment(attachment_id: "att_123")

    assert_equal audio_content, result[:content]
    assert_equal "audio/ogg", result[:content_type]
    assert_equal "voice_message.ogg", result[:filename]
  end

  test "download_attachment raises Error when attachment_id is blank" do
    assert_raises(UnipileClient::Error) do
      @client.download_attachment(attachment_id: "")
    end
  end

  # ==========================================
  # connected? Tests
  # ==========================================

  test "connected? returns true when API is accessible" do
    stub_request(:get, "https://api.test.unipile.com/api/v1/accounts/test_account_id_456")
      .to_return(status: 200, body: { id: "test_account_id_456" }.to_json)

    assert @client.connected?
  end

  test "connected? returns false when API returns error" do
    stub_request(:get, "https://api.test.unipile.com/api/v1/accounts/test_account_id_456")
      .to_return(status: 401, body: { error: "Unauthorized" }.to_json)

    assert_not @client.connected?
  end

  # ==========================================
  # whatsapp_phone_number Tests
  # ==========================================

  test "whatsapp_phone_number returns phone from account info" do
    stub_request(:get, "https://api.test.unipile.com/api/v1/accounts/test_account_id_456")
      .to_return(
        status: 200,
        body: { connection: { phone_number: "+33612345678" } }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    assert_equal "+33612345678", @client.whatsapp_phone_number
  end

  test "whatsapp_phone_number returns nil on error" do
    stub_request(:get, "https://api.test.unipile.com/api/v1/accounts/test_account_id_456")
      .to_return(status: 500, body: { error: "Server error" }.to_json)

    assert_nil @client.whatsapp_phone_number
  end

  # ==========================================
  # start_new_chat Tests
  # ==========================================

  test "start_new_chat creates chat with phone number" do
    stub_request(:post, "https://api.test.unipile.com/api/v1/chats")
      .with(headers: { 'X-API-KEY' => 'test_api_key_123' })
      .to_return(
        status: 200,
        body: { chat_id: "chat_new_123", message_id: "msg_456" }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    result = @client.start_new_chat(phone_number: "+33612345678", text: "Bonjour!")

    assert_equal "chat_new_123", result["chat_id"]
    assert_equal "msg_456", result["message_id"]
  end

  # ==========================================
  # list_chats Tests
  # ==========================================

  test "list_chats returns chats array" do
    stub_request(:get, "https://api.test.unipile.com/api/v1/chats")
      .with(
        query: { "account_id" => "test_account_id_456", "limit" => "20" },
        headers: { 'X-API-KEY' => 'test_api_key_123' }
      )
      .to_return(
        status: 200,
        body: { chats: [{ id: "chat_1" }, { id: "chat_2" }] }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    result = @client.list_chats

    assert_equal 2, result["chats"].length
  end

  # ==========================================
  # Error Handling Tests
  # ==========================================

  test "ApiError includes status and body" do
    stub_request(:get, "https://api.test.unipile.com/api/v1/accounts/test_account_id_456")
      .to_return(
        status: 500,
        body: { error: "Internal server error", details: "Something went wrong" }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    error = assert_raises(UnipileClient::ApiError) do
      @client.get_account_info
    end

    assert_equal 500, error.status
    assert_includes error.message, "Unipile API error"
  end
end
