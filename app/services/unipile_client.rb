# frozen_string_literal: true

# Service for interacting with the Unipile WhatsApp API
# Handles sending messages, attachments, and account management
#
# Configuration is read from AppSetting:
#   - unipile_dsn: Base URL (e.g., "https://api1.unipile.com:13211")
#   - unipile_api_key: API key for Authorization header
#   - unipile_account_id: WhatsApp account ID
#
# Usage:
#   client = UnipileClient.new
#   client.send_message(chat_id: "chat_123", text: "Hello!")
#   client.send_attachment(chat_id: "chat_123", file_path: "/path/to/file.pdf", filename: "quote.pdf")
#   client.get_account_info
#   client.download_attachment(attachment_id: "att_123")
#
class UnipileClient
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
  class AuthenticationError < ApiError; end
  class NotFoundError < ApiError; end
  class RateLimitError < ApiError; end

  DEFAULT_TIMEOUT = 30

  def initialize(dsn: nil, api_key: nil, account_id: nil)
    @dsn = normalize_dsn(dsn || settings.unipile_dsn)
    @api_key = api_key || settings.unipile_api_key
    @account_id = account_id || settings.unipile_account_id

    validate_configuration!
  end

  # Send a text message to a chat
  # @param chat_id [String] The Unipile chat ID
  # @param text [String] The message content
  # @return [Hash] API response with message_id
  def send_message(chat_id:, text:)
    validate_presence!(chat_id: chat_id, text: text)

    response = multipart_connection.post("api/v1/chats/#{chat_id}/messages") do |req|
      req.body = { text: text }
    end

    handle_response(response)
  end

  # Send an attachment (PDF, image, etc.) to a chat
  # @param chat_id [String] The Unipile chat ID
  # @param file_path [String] Path to the file to send
  # @param filename [String] Name to display for the file
  # @param text [String, nil] Optional message to accompany the attachment
  # @return [Hash] API response with message_id
  def send_attachment(chat_id:, file_path:, filename:, text: nil)
    validate_presence!(chat_id: chat_id, file_path: file_path, filename: filename)
    
    unless File.exist?(file_path)
      raise Error, "File not found: #{file_path}"
    end

    file = Faraday::Multipart::FilePart.new(
      file_path,
      mime_type_for(filename),
      filename
    )

    body = { attachments: file }
    body[:text] = text if text.present?

    response = multipart_connection.post("api/v1/chats/#{chat_id}/messages") do |req|
      req.body = body
    end

    handle_response(response)
  end

  # Send an attachment from IO/StringIO (for in-memory PDFs)
  # @param chat_id [String] The Unipile chat ID
  # @param io [IO, StringIO] The IO object containing file data
  # @param filename [String] Name to display for the file
  # @param content_type [String] MIME type of the file
  # @param text [String, nil] Optional message to accompany the attachment
  # @return [Hash] API response with message_id
  def send_attachment_from_io(chat_id:, io:, filename:, content_type:, text: nil)
    validate_presence!(chat_id: chat_id, io: io, filename: filename)

    file = Faraday::Multipart::FilePart.new(
      io,
      content_type,
      filename
    )

    body = { attachments: file }
    body[:text] = text if text.present?

    response = multipart_connection.post("api/v1/chats/#{chat_id}/messages") do |req|
      req.body = body
    end

    handle_response(response)
  end

  # Get account information for the connected WhatsApp account
  # @return [Hash] Account details including phone number, status
  def get_account_info
    response = connection.get("api/v1/accounts/#{@account_id}")
    handle_response(response)
  end

  # Download an attachment from a message
  # @param attachment_id [String] The attachment ID from the message
  # @return [Hash] { content: binary_data, content_type: "audio/ogg", filename: "audio.ogg" }
  def download_attachment(attachment_id:)
    validate_presence!(attachment_id: attachment_id)

    response = connection.get("api/v1/attachments/#{attachment_id}")
    
    if response.success?
      {
        content: response.body,
        content_type: response.headers['content-type'],
        filename: extract_filename(response.headers)
      }
    else
      handle_response(response)
    end
  end

  # Start a new chat with a user (when no chat_id exists)
  # @param phone_number [String] Phone number in E.164 format
  # @param text [String] Initial message
  # @return [Hash] API response with chat_id and message_id
  def start_new_chat(phone_number:, text:)
    validate_presence!(phone_number: phone_number, text: text)

    # WhatsApp attendee ID format: phone@s.whatsapp.net
    attendee_id = "#{phone_number.delete('+')}@s.whatsapp.net"

    response = multipart_connection.post("api/v1/chats") do |req|
      req.body = {
        account_id: @account_id,
        text: text,
        attendees_ids: attendee_id
      }
    end

    handle_response(response)
  end

  # List recent chats
  # @param limit [Integer] Number of chats to retrieve
  # @return [Hash] API response with chats array
  def list_chats(limit: 20)
    response = connection.get("api/v1/chats") do |req|
      req.params['account_id'] = @account_id
      req.params['limit'] = limit
    end

    handle_response(response)
  end


# Get a single message by ID
# @param message_id [String]
# @return [Hash]
def get_message(message_id:)
  validate_presence!(message_id: message_id)

  response = connection.get("api/v1/messages/#{message_id}")
  handle_response(response)
end
  # Get messages from a specific chat
  # @param chat_id [String] The chat ID
  # @param limit [Integer] Number of messages to retrieve
  # @return [Hash] API response with messages array
  def get_chat_messages(chat_id:, limit: 100)
    validate_presence!(chat_id: chat_id)

    response = connection.get("api/v1/chats/#{chat_id}/messages") do |req|
      req.params['limit'] = limit
    end

    handle_response(response)
  end

  # Check if the Unipile connection is working
  # @return [Boolean]
  def connected?
    get_account_info
    true
  rescue ApiError
    false
  end

  # Get the connected WhatsApp phone number
  # @return [String, nil] Phone number or nil if not connected
  def whatsapp_phone_number
    info = get_account_info
    info.dig('connection', 'phone_number') || info.dig('phone_number')
  rescue ApiError
    nil
  end


# Download an attachment that belongs to a specific message.
# Unipile uses message-scoped attachment download for WhatsApp voice notes.
# GET /api/v1/messages/:message_id/attachments/:attachment_id
# @return [Hash] { content: binary_data, content_type: String, filename: String }
def download_message_attachment(message_id:, attachment_id:)
  validate_presence!(message_id: message_id, attachment_id: attachment_id)

  response = connection.get("api/v1/messages/#{message_id}/attachments/#{attachment_id}")

  if response.success?
    {
      content: response.body,
      content_type: response.headers['content-type'],
      filename: "attachment"
    }
  else
    handle_response(response)
  end
end
  private

  def settings
    @settings ||= AppSetting.instance
  end


  # Accept values like:
  # - "https://api10.unipile.com:14054"
  # - "http://api10.unipile.com:14054"
  # - "api10.unipile.com:14054"   (we auto-prefix with https://)
  def normalize_dsn(value)
    return nil if value.blank?

    v = value.to_s.strip
    v = "https://#{v}" unless v.match?(/\Ahttps?:\/\//)
    v
  end

  def validate_configuration!
    errors = []
    errors << "unipile_dsn is not configured" if @dsn.blank?
    errors << "unipile_api_key is not configured" if @api_key.blank?
    errors << "unipile_account_id is not configured" if @account_id.blank?

    raise ConfigurationError, errors.join(", ") if errors.any?
  end

  def validate_presence!(**params)
    missing = params.select { |_, v| v.blank? }.keys
    raise Error, "Missing required parameters: #{missing.join(', ')}" if missing.any?
  end

  def connection
    @connection ||= Faraday.new(url: @dsn) do |f|
      f.request :json
      f.response :json, content_type: /\bjson$/
      f.headers['X-API-KEY'] = @api_key
      f.headers['Accept'] = 'application/json'
      f.options.timeout = DEFAULT_TIMEOUT
      f.options.open_timeout = 10
    end
  end

  def multipart_connection
    @multipart_connection ||= Faraday.new(url: @dsn) do |f|
      f.request :multipart
      f.request :url_encoded
      f.response :json, content_type: /\bjson$/
      f.headers['X-API-KEY'] = @api_key
      f.headers['Accept'] = 'application/json'
      f.options.timeout = DEFAULT_TIMEOUT * 2 # Longer timeout for file uploads
      f.options.open_timeout = 10
    end
  end

  def handle_response(response)
    case response.status
    when 200..299
      response.body || {}
    when 401
      raise AuthenticationError.new(
        "Unipile authentication failed - check API key",
        status: response.status,
        body: response.body
      )
    when 404
      raise NotFoundError.new(
        "Resource not found",
        status: response.status,
        body: response.body
      )
    when 429
      raise RateLimitError.new(
        "Unipile rate limit exceeded",
        status: response.status,
        body: response.body
      )
    else
      error_message = extract_error_message(response)
      raise ApiError.new(
        "Unipile API error: #{error_message}",
        status: response.status,
        body: response.body
      )
    end
  end

  def extract_error_message(response)
    if response.body.is_a?(Hash)
      response.body['message'] || response.body['error'] || "Unknown error"
    else
      "HTTP #{response.status}"
    end
  end

  def extract_filename(headers)
    content_disposition = headers['content-disposition']
    return 'attachment' unless content_disposition

    match = content_disposition.match(/filename="?([^";\s]+)"?/)
    match ? match[1] : 'attachment'
  end

  def mime_type_for(filename)
    extension = File.extname(filename).downcase
    MIME_TYPES[extension] || 'application/octet-stream'
  end

  MIME_TYPES = {
    '.pdf' => 'application/pdf',
    '.png' => 'image/png',
    '.jpg' => 'image/jpeg',
    '.jpeg' => 'image/jpeg',
    '.gif' => 'image/gif',
    '.mp3' => 'audio/mpeg',
    '.ogg' => 'audio/ogg',
    '.opus' => 'audio/opus',
    '.m4a' => 'audio/mp4',
    '.wav' => 'audio/wav',
    '.mp4' => 'video/mp4',
    '.doc' => 'application/msword',
    '.docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.xls' => 'application/vnd.ms-excel',
    '.xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  }.freeze
end
