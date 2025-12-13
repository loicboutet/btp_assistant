# frozen_string_literal: true

# Controller for handling artisan (User) access via signed URLs
# Artisans don't have passwords - they access via time-limited signed URLs
# sent to them on WhatsApp
class UserSessionsController < ApplicationController
  layout 'client'

  # GET /u/:token
  # Entry point for artisan web access
  def show
    result = SignedUrlService.verify(params[:token])

    # Important: set locale based on the user when we can.
    # This controller is outside Portal::BaseController, so without this the flash
    # might display "Translation missing: en..." even for French/Turkish users.
    locale = result[:user]&.preferred_language
    locale = locale.presence_in(%w[fr tr]) || I18n.default_locale

    I18n.with_locale(locale) do
      case result[:status]
      when :valid
        handle_valid_token(result[:user])
      when :expired
        handle_expired_token(result[:user])
      when :invalid
        handle_invalid_token
      end
    end
  end

  private

  def handle_valid_token(user)
    # Create session for user
    session[:user_id] = user.id
    session[:user_signed_in_at] = Time.current.to_i

    # Update user activity
    user.record_activity!

    # Log the access
    SystemLog.log_info(
      'user_web_access',
      description: "User #{user.display_name} accessed web via signed URL",
      user: user,
      request: request
    )

    redirect_to client_dashboard_path, notice: t('user_sessions.welcome_back', name: user.display_name)
  end

  def handle_expired_token(user)
    @user = user

    # Log the expired access attempt
    SystemLog.log_info(
      'user_expired_link',
      description: "User #{user.display_name} tried expired link",
      user: user,
      request: request
    )

    # In the future, we'll automatically send a new link via WhatsApp here
    # For now, just show a message

    render :expired
  end

  def handle_invalid_token
    # Log the invalid access attempt
    SystemLog.log_warning(
      'user_invalid_link',
      description: "Invalid signed URL access attempt",
      metadata: { token_prefix: params[:token]&.first(10) },
      request: request
    )

    render :invalid
  end
end
