# frozen_string_literal: true

module Admin
  # Base controller for all admin controllers
  # Requires admin authentication and provides common functionality
  class BaseController < ApplicationController
    before_action :authenticate_admin!
    layout 'admin'

    protected

    # Override the default Devise helper for admin area
    def current_admin
      @current_admin ||= warden.authenticate(scope: :admin)
    end

    def admin_signed_in?
      !!current_admin
    end

    helper_method :current_admin, :admin_signed_in?

    # Log admin actions for audit trail
    def log_admin_action(event, description = nil, metadata = {})
      SystemLog.log_audit(
        event,
        description: description,
        metadata: metadata,
        admin_user: current_admin,
        request: request
      )
    end

    # Simple pagination helper
    # @param scope [ActiveRecord::Relation] The relation to paginate
    # @param per_page [Integer] Number of records per page
    # @return [ActiveRecord::Relation] Paginated relation with pagination metadata
    def paginate(scope, per_page: 50)
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
