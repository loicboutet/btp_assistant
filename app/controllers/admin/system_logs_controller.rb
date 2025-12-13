# frozen_string_literal: true

module Admin
  class SystemLogsController < Admin::BaseController
    def index
      @filters = {
        q: params[:q].to_s.strip.presence,
        log_type: params[:log_type].to_s.strip.presence,
        event: params[:event].to_s.strip.presence,
        user_id: params[:user_id].to_s.strip.presence,
        admin_id: params[:admin_id].to_s.strip.presence,
        from: params[:from].to_s.strip.presence,
        to: params[:to].to_s.strip.presence
      }

      logs = SystemLog.all

      logs = logs.where(log_type: @filters[:log_type]) if @filters[:log_type].present?
      logs = logs.where(event: @filters[:event]) if @filters[:event].present?
      logs = logs.where(user_id: @filters[:user_id]) if @filters[:user_id].present?
      logs = logs.where(admin_id: @filters[:admin_id]) if @filters[:admin_id].present?

      if @filters[:from].present?
        from_time = Time.zone.parse(@filters[:from]) rescue nil
        logs = logs.where('created_at >= ?', from_time.beginning_of_day) if from_time
      end

      if @filters[:to].present?
        to_time = Time.zone.parse(@filters[:to]) rescue nil
        logs = logs.where('created_at <= ?', to_time.end_of_day) if to_time
      end

      if @filters[:q].present?
        q = "%#{@filters[:q]}%"
        logs = logs.where('event LIKE ? OR description LIKE ?', q, q)
      end

      logs = logs.includes(:user, :admin_user).order(created_at: :desc)
      @system_logs = paginate(logs, per_page: 50)

      @log_types = %w[info warning error audit]
      @events = SystemLog.distinct.order(:event).pluck(:event)
      @users_for_filter = User.order(:id).limit(200)
      @admins_for_filter = AdminUser.order(:id).limit(200)
    end

    def show
      @system_log = SystemLog.includes(:user, :admin_user).find(params[:id])
    end
  end
end
