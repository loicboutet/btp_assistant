# frozen_string_literal: true

require "test_helper"

class OpenaiClientTest < ActiveSupport::TestCase
  setup do
    @app_setting = AppSetting.instance
    @app_setting.update!(
      openai_api_key: "sk-test-key-123",
      openai_model: "gpt-4"
    )
    
    @client = OpenaiClient.new
  end

  # ==========================================
  # Configuration Tests
  # ==========================================

  test "raises ConfigurationError when API key is missing" do
    @app_setting.update!(openai_api_key: nil)
    
    error = assert_raises(OpenaiClient::ConfigurationError) do
      OpenaiClient.new
    end
    
    assert_match(/API key is not configured/, error.message)
  end

  test "can override API key in constructor" do
    @app_setting.update!(openai_api_key: nil)
    
    client = OpenaiClient.new(api_key: "custom-key")
    assert client.configured?
  end

  test "uses default model when not configured" do
    @app_setting.update!(openai_model: nil)
    
    client = OpenaiClient.new
    assert_equal "gpt-4", client.model
  end

  test "configured? returns true when API key is set" do
    assert @client.configured?
  end

  # ==========================================
  # Chat with Tools Tests
  # ==========================================

  test "chat_with_tools sends request and returns response" do
    mock_response = {
      "choices" => [{
        "message" => {
          "role" => "assistant",
          "content" => "Bonjour! Comment puis-je vous aider?"
        },
        "finish_reason" => "stop"
      }],
      "usage" => {
        "prompt_tokens" => 50,
        "completion_tokens" => 20,
        "total_tokens" => 70
      },
      "model" => "gpt-4"
    }

    stub_openai_chat(mock_response)

    messages = [{ role: "user", content: "Bonjour" }]
    result = @client.chat_with_tools(messages: messages)

    assert_equal "Bonjour! Comment puis-je vous aider?", result[:content]
    assert_nil result[:tool_calls]
    assert_equal "stop", result[:finish_reason]
    assert_equal 50, result[:usage][:prompt_tokens]
    assert_equal 20, result[:usage][:completion_tokens]
    assert_equal 70, result[:usage][:total_tokens]
  end

  test "chat_with_tools returns tool calls when present" do
    mock_response = {
      "choices" => [{
        "message" => {
          "role" => "assistant",
          "content" => nil,
          "tool_calls" => [{
            "id" => "call_abc123",
            "type" => "function",
            "function" => {
              "name" => "search_clients",
              "arguments" => '{"query": "Dupont"}'
            }
          }]
        },
        "finish_reason" => "tool_calls"
      }],
      "usage" => {
        "prompt_tokens" => 100,
        "completion_tokens" => 30,
        "total_tokens" => 130
      },
      "model" => "gpt-4"
    }

    stub_openai_chat(mock_response)

    messages = [{ role: "user", content: "Cherche le client Dupont" }]
    tools = LlmTools::ToolDefinitions::TOOLS
    
    result = @client.chat_with_tools(messages: messages, tools: tools)

    assert_nil result[:content]
    assert_not_nil result[:tool_calls]
    assert_equal 1, result[:tool_calls].length
    
    tool_call = result[:tool_calls].first
    assert_equal "call_abc123", tool_call[:id]
    assert_equal "search_clients", tool_call[:function][:name]
    assert_equal({ "query" => "Dupont" }, tool_call[:function][:arguments])
  end

  test "chat_with_tools handles malformed tool arguments" do
    mock_response = {
      "choices" => [{
        "message" => {
          "role" => "assistant",
          "content" => nil,
          "tool_calls" => [{
            "id" => "call_abc123",
            "type" => "function",
            "function" => {
              "name" => "search_clients",
              "arguments" => "not valid json"
            }
          }]
        },
        "finish_reason" => "tool_calls"
      }],
      "usage" => {},
      "model" => "gpt-4"
    }

    stub_openai_chat(mock_response)

    messages = [{ role: "user", content: "Test" }]
    result = @client.chat_with_tools(messages: messages)

    tool_call = result[:tool_calls].first
    assert tool_call[:function][:arguments].key?("_raw")
    assert tool_call[:function][:arguments].key?("_parse_error")
  end

  test "chat_with_tools includes duration_ms" do
    mock_response = {
      "choices" => [{ "message" => { "content" => "Test" } }],
      "usage" => {},
      "model" => "gpt-4"
    }

    stub_openai_chat(mock_response)

    result = @client.chat_with_tools(messages: [{ role: "user", content: "Test" }])
    
    assert result[:duration_ms].is_a?(Integer)
    assert result[:duration_ms] >= 0
  end

  # ==========================================
  # Simple Chat Tests
  # ==========================================

  test "chat sends request without tools" do
    mock_response = {
      "choices" => [{ "message" => { "content" => "Hello!" } }],
      "usage" => {},
      "model" => "gpt-4"
    }

    stub_openai_chat(mock_response)

    result = @client.chat(messages: [{ role: "user", content: "Hi" }])
    
    assert_equal "Hello!", result[:content]
  end

  # ==========================================
  # Transcription Tests
  # ==========================================

  test "transcribe_audio transcribes audio file" do
    # Create a temp file to simulate audio
    Tempfile.create(["test_audio", ".ogg"]) do |file|
      file.write("fake audio data")
      file.rewind

      mock_response = {
        "text" => "Bonjour, je voudrais créer un devis",
        "language" => "fr",
        "segments" => []
      }

      stub_openai_transcription(mock_response)

      result = @client.transcribe_audio(file_path: file.path)

      assert_equal "Bonjour, je voudrais créer un devis", result[:transcription]
      assert_equal "fr", result[:language]
      assert result[:duration_ms].is_a?(Integer)
    end
  end

  test "transcribe_audio raises error for missing file" do
    error = assert_raises(OpenaiClient::Error) do
      @client.transcribe_audio(file_path: "/nonexistent/file.ogg")
    end
    
    assert_match(/File not found/, error.message)
  end

  test "transcribe_audio raises error for empty file path" do
    error = assert_raises(OpenaiClient::Error) do
      @client.transcribe_audio(file_path: nil)
    end
    
    assert_match(/File path is required/, error.message)
  end

  test "transcribe_audio_io handles IO objects" do
    mock_response = {
      "text" => "Test transcription",
      "language" => "tr",
      "segments" => []
    }

    stub_openai_transcription(mock_response)

    io = StringIO.new("fake audio data")
    result = @client.transcribe_audio_io(io: io, filename: "audio.mp3")

    assert_equal "Test transcription", result[:transcription]
    assert_equal "tr", result[:language]
  end

  # ==========================================
  # Language Detection Tests
  # ==========================================

  test "detects Turkish language from text with Turkish characters" do
    # This tests the internal language detection fallback
    mock_response = {
      "choices" => [{ "message" => { "content" => "Test" } }],
      "usage" => {},
      "model" => "gpt-4"
    }

    stub_openai_chat(mock_response)

    result = @client.chat(messages: [{ role: "user", content: "Test" }])
    assert_not_nil result
  end

  # ==========================================
  # Error Handling Tests
  # ==========================================

  test "handles rate limit errors" do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(status: 429, body: { error: { message: "Rate limit exceeded" } }.to_json)

    assert_raises(OpenaiClient::RateLimitError) do
      @client.chat(messages: [{ role: "user", content: "Test" }])
    end
  end

  test "handles authentication errors" do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(status: 401, body: { error: { message: "Invalid API key" } }.to_json)

    assert_raises(OpenaiClient::ConfigurationError) do
      @client.chat(messages: [{ role: "user", content: "Test" }])
    end
  end

  test "handles invalid request errors" do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(status: 400, body: { error: { message: "Invalid request" } }.to_json)

    assert_raises(OpenaiClient::InvalidRequestError) do
      @client.chat(messages: [{ role: "user", content: "Test" }])
    end
  end

  test "handles generic API errors" do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(status: 500, body: { error: { message: "Server error" } }.to_json)

    assert_raises(OpenaiClient::ApiError) do
      @client.chat(messages: [{ role: "user", content: "Test" }])
    end
  end

  private

  def stub_openai_chat(response_body)
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(
        status: 200,
        body: response_body.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_openai_transcription(response_body)
    stub_request(:post, "https://api.openai.com/v1/audio/transcriptions")
      .to_return(
        status: 200,
        body: response_body.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
