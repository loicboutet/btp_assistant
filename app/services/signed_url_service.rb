# frozen_string_literal: true

# Service for generating and verifying signed URLs for artisan (User) access
# Users don't have passwords - they access via time-limited signed URLs
# sent to them on WhatsApp
#
# Usage:
#   SignedUrlService.generate_url(user) # => "https://example.com/u/abc123..."
#   SignedUrlService.verify("abc123...") # => { status: :valid, user: User }
#   SignedUrlService.extract_user_from_expired("abc123...") # => User or nil
#
class SignedUrlService
  # Token structure: user_id:timestamp:signature
  # Signature = HMAC(secret, "user_id:timestamp")
  
  class << self
    # Generate a signed URL for a user
    # @param user [User] the user to generate URL for
    # @return [String] the full signed URL
    def generate_url(user)
      token = generate_token(user)
      Rails.application.routes.url_helpers.signed_user_access_url(token: token, host: default_host)
    end

    # Generate just the token (useful for testing)
    # @param user [User] the user to generate token for
    # @return [String] the signed token
    def generate_token(user)
      timestamp = Time.current.to_i
      data = "#{user.id}:#{timestamp}"
      signature = generate_signature(data)
      
      Base64.urlsafe_encode64("#{data}:#{signature}", padding: false)
    end

    # Verify a token and return the result
    # @param token [String] the token to verify
    # @return [Hash] { status: :valid/:expired/:invalid, user: User/nil }
    def verify(token)
      return { status: :invalid, user: nil } if token.blank?

      begin
        decoded = Base64.urlsafe_decode64(token)
        parts = decoded.split(':')
        
        return { status: :invalid, user: nil } if parts.length != 3

        user_id, timestamp, signature = parts
        data = "#{user_id}:#{timestamp}"
        
        # Verify signature
        expected_signature = generate_signature(data)
        unless secure_compare(signature, expected_signature)
          return { status: :invalid, user: nil }
        end

        # Find user
        user = User.find_by(id: user_id)
        return { status: :invalid, user: nil } unless user

        # Check expiration
        token_time = Time.at(timestamp.to_i)
        if token_time < expiration_minutes.minutes.ago
          return { status: :expired, user: user }
        end

        { status: :valid, user: user }
      rescue ArgumentError, ActiveRecord::RecordNotFound => e
        Rails.logger.warn "SignedUrlService: Invalid token - #{e.message}"
        { status: :invalid, user: nil }
      end
    end

    # Extract user from an expired token (for sending new link)
    # @param token [String] the expired token
    # @return [User, nil] the user if token was valid but expired
    def extract_user_from_expired(token)
      result = verify(token)
      result[:status] == :expired ? result[:user] : nil
    end

    # Check if a token is valid (convenience method)
    # @param token [String] the token to check
    # @return [Boolean]
    def valid?(token)
      verify(token)[:status] == :valid
    end

    # Get the user from a valid token (convenience method)
    # @param token [String] the token
    # @return [User, nil]
    def user_from_token(token)
      result = verify(token)
      result[:status] == :valid ? result[:user] : nil
    end

    private

    def generate_signature(data)
      OpenSSL::HMAC.hexdigest('SHA256', secret_key, data)
    end

    def secure_compare(a, b)
      ActiveSupport::SecurityUtils.secure_compare(a, b)
    end

    def secret_key
      Rails.application.secret_key_base
    end

    def expiration_minutes
      AppSetting.signed_url_expiration_minutes rescue 30
    end

    def default_host
      Rails.application.config.action_mailer.default_url_options&.dig(:host) || 'localhost:3000'
    end
  end
end
