# frozen_string_literal: true

# Service for interacting with OpenAI APIs (GPT-4 and Whisper)
# Handles chat completions with function calling and audio transcription
#
# Configuration is read from AppSetting.instance:
#   - openai_api_key: API key for OpenAI
#   - openai_model: Model name (default: "gpt-4")
#
# Usage:
#   client = OpenaiClient.new
#   
#   # Chat with tools (function calling)
#   response = client.chat_with_tools(
#     messages: [{ role: "user", content: "Crée un devis pour Dupont" }],
#     tools: LlmTools::ToolDefinitions::TOOLS
#   )
#   
#   # Audio transcription
#   result = client.transcribe_audio(file_path: "/path/to/audio.ogg")
#   # => { transcription: "Bonjour...", language: "fr" }
#
class OpenaiClient
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class ApiError < Error
    attr_reader :status, :body
    
    def initialize(message, status: nil, body: nil)
      super(message)
      @status = status
      @body = body
    end
  end
  class RateLimitError < ApiError; end
  class InvalidRequestError < ApiError; end

  DEFAULT_MODEL = "gpt-4"
  WHISPER_MODEL = "whisper-1"

  def initialize(api_key: nil, model: nil)
    @api_key = api_key || settings.openai_api_key
    @model = model || settings.openai_model || DEFAULT_MODEL
    
    validate_configuration!
  end

  # Chat completion with function calling (tools)
  # @param messages [Array<Hash>] Conversation messages
  # @param tools [Array<Hash>] Tool definitions (OpenAI function schemas)
  # @param model [String, nil] Override model for this request
  # @param temperature [Float] Sampling temperature (0-2)
  # @return [Hash] Response with :content, :tool_calls, :usage
  def chat_with_tools(messages:, tools: nil, model: nil, temperature: 0.7)
    start_time = Time.current
    
    parameters = {
      model: model || @model,
      messages: messages,
      temperature: temperature
    }
    
    # Add tools if provided
    if tools.present?
      parameters[:tools] = tools
      parameters[:tool_choice] = "auto"
    end

    begin
      response = client.chat(parameters: parameters)
      
      duration_ms = ((Time.current - start_time) * 1000).to_i
      
      parse_chat_response(response, duration_ms: duration_ms)
    rescue Faraday::Error => e
      handle_api_error(e)
    end
  end

  # Simple chat without tools (convenience method)
  # @param messages [Array<Hash>] Conversation messages
  # @param model [String, nil] Override model
  # @return [Hash] Response with :content, :usage
  def chat(messages:, model: nil, temperature: 0.7)
    chat_with_tools(messages: messages, tools: nil, model: model, temperature: temperature)
  end

  # Transcribe audio file using Whisper
  # @param file_path [String] Path to audio file
  # @param language [String, nil] Language hint (ISO 639-1 code: "fr", "tr")
  # @return [Hash] { transcription: String, language: String, duration_ms: Integer }
  def transcribe_audio(file_path:, language: nil)
    validate_file!(file_path)
    
    start_time = Time.current
    
    begin
      parameters = {
        model: WHISPER_MODEL,
        file: File.open(file_path, "rb"),
        response_format: "verbose_json" # Includes language detection
      }
      
      # Add language hint if provided
      parameters[:language] = language if language.present?

      response = client.audio.transcribe(parameters: parameters)
      
      duration_ms = ((Time.current - start_time) * 1000).to_i
      
      {
        transcription: response["text"],
        language: response["language"] || language || detect_language_from_text(response["text"]),
        duration_ms: duration_ms,
        segments: response["segments"]
      }
    rescue Faraday::Error => e
      handle_api_error(e)
    ensure
      # Ensure file handle is closed
      # File.open with block handles this automatically
    end
  end

  # Transcribe audio from IO/binary data
  # @param io [IO, StringIO, Tempfile] Audio data
  # @param filename [String] Filename with extension (for format detection)
  # @param language [String, nil] Language hint
  # @return [Hash] { transcription: String, language: String, duration_ms: Integer }
  def transcribe_audio_io(io:, filename: "audio.ogg", language: nil)
    # Create a temp file for the IO content
    extension = File.extname(filename)
    
    Tempfile.create(["whisper_audio", extension]) do |temp_file|
      temp_file.binmode
      
      if io.respond_to?(:read)
        temp_file.write(io.read)
        io.rewind if io.respond_to?(:rewind)
      else
        temp_file.write(io)
      end
      
      temp_file.rewind
      transcribe_audio(file_path: temp_file.path, language: language)
    end
  end

  # Check if OpenAI is properly configured
  # @return [Boolean]
  def configured?
    @api_key.present?
  end

  # Get current model
  # @return [String]
  attr_reader :model

  private

  def settings
    @settings ||= AppSetting.instance
  end

  def validate_configuration!
    raise ConfigurationError, "OpenAI API key is not configured" if @api_key.blank?
  end

  def validate_file!(file_path)
    raise Error, "File path is required" if file_path.blank?
    raise Error, "File not found: #{file_path}" unless File.exist?(file_path)
    raise Error, "File is empty: #{file_path}" if File.zero?(file_path)
  end

  def client
    @client ||= OpenAI::Client.new(access_token: @api_key)
  end

  def parse_chat_response(response, duration_ms: 0)
    choice = response.dig("choices", 0)
    message = choice&.dig("message") || {}
    usage = response["usage"] || {}

    {
      content: message["content"],
      tool_calls: parse_tool_calls(message["tool_calls"]),
      finish_reason: choice&.dig("finish_reason"),
      usage: {
        prompt_tokens: usage["prompt_tokens"],
        completion_tokens: usage["completion_tokens"],
        total_tokens: usage["total_tokens"]
      },
      duration_ms: duration_ms,
      model: response["model"]
    }
  end

  def parse_tool_calls(tool_calls)
    return nil if tool_calls.blank?

    tool_calls.map do |tc|
      {
        id: tc["id"],
        type: tc["type"],
        function: {
          name: tc.dig("function", "name"),
          arguments: parse_json_safely(tc.dig("function", "arguments"))
        }
      }
    end
  end

  def parse_json_safely(json_string)
    return {} if json_string.blank?
    JSON.parse(json_string)
  rescue JSON::ParserError => e
    Rails.logger.warn "OpenaiClient: Failed to parse tool arguments: #{e.message}"
    { "_raw" => json_string, "_parse_error" => e.message }
  end

  def detect_language_from_text(text)
    return "fr" if text.blank?
    
    # Simple heuristic: check for Turkish-specific characters
    turkish_chars = /[ğüşıöçĞÜŞİÖÇ]/
    text.match?(turkish_chars) ? "tr" : "fr"
  end

  def handle_api_error(error)
    message = extract_error_message(error)
    status = error.respond_to?(:response_status) ? error.response_status : nil
    body = error.respond_to?(:response_body) ? error.response_body : nil

    Rails.logger.error "OpenaiClient API error: #{message}"

    case status
    when 429
      raise RateLimitError.new("OpenAI rate limit exceeded: #{message}", status: status, body: body)
    when 400
      raise InvalidRequestError.new("Invalid request to OpenAI: #{message}", status: status, body: body)
    when 401
      raise ConfigurationError, "OpenAI authentication failed - check API key"
    else
      raise ApiError.new("OpenAI API error: #{message}", status: status, body: body)
    end
  end

  def extract_error_message(error)
    if error.respond_to?(:response_body) && error.response_body.is_a?(Hash)
      error.response_body.dig("error", "message") || error.message
    else
      error.message
    end
  end
end
