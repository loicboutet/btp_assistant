# frozen_string_literal: true

module Portal
  # Base controller for artisan (User) web interface
  # Authentication is via signed URLs, not Devise passwords
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :check_session_freshness

    around_action :switch_locale

    layout 'client'

    protected

    # Get current user from session (set by UserSessionsController)
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def user_signed_in?
      !!current_user
    end

    helper_method :current_user, :user_signed_in?

    def authenticate_user!
      unless user_signed_in?
        redirect_to root_path, alert: t('user_sessions.link_invalid')
      end
    end

    def switch_locale(&action)
      locale = current_user&.preferred_language
      locale = locale.presence_in(%w[fr tr]) || I18n.default_locale

      I18n.with_locale(locale, &action)
    end

    # Check if the session is still fresh (within reasonable time)
    # This is a secondary check - the signed URL has its own expiration
    def check_session_freshness
      return unless user_signed_in?

      signed_in_at = session[:user_signed_in_at]
      return unless signed_in_at

      # Session valid for 2 hours of activity
      max_session_age = 2.hours
      if Time.at(signed_in_at) < max_session_age.ago
        clear_user_session
        redirect_to root_path, alert: t('user_sessions.session_expired')
      end
    end

    # Update last activity timestamp
    def touch_session
      session[:user_signed_in_at] = Time.current.to_i
    end

    # Clear user session
    def clear_user_session
      session.delete(:user_id)
      session.delete(:user_signed_in_at)
      @current_user = nil
    end

    # Log user action
    def log_user_action(event, description = nil, metadata = {})
      SystemLog.log_info(
        event,
        description: description,
        user: current_user,
        metadata: metadata,
        request: request
      )
    end

    # Simple pagination helper
    # @param scope [ActiveRecord::Relation] The relation to paginate
    # @param per_page [Integer] Number of records per page
    # @return [ActiveRecord::Relation] Paginated relation with pagination metadata
    def paginate(scope, per_page: 20)
      page = (params[:page] || 1).to_i
      page = 1 if page < 1

      total_count = scope.count
      @total_pages = (total_count / per_page.to_f).ceil
      @total_pages = 1 if @total_pages < 1
      @current_page = [page, @total_pages].min

      offset = (@current_page - 1) * per_page
      scope.offset(offset).limit(per_page)
    end

    helper_method :paginate
  end
end
