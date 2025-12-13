# frozen_string_literal: true

module Admin
  class LlmConversationsController < Admin::BaseController
    def index
      @filters = {
        user_id: params[:user_id].to_s.strip.presence,
        tool_name: params[:tool_name].to_s.strip.presence,
        with_errors: params[:with_errors].to_s.strip.presence,
        from: params[:from].to_s.strip.presence,
        to: params[:to].to_s.strip.presence
      }

      scope = LlmConversation.all

      scope = scope.where(user_id: @filters[:user_id]) if @filters[:user_id].present?
      scope = scope.where(tool_name: @filters[:tool_name]) if @filters[:tool_name].present?

      if ActiveModel::Type::Boolean.new.cast(@filters[:with_errors])
        scope = scope.with_errors
      end

      if @filters[:from].present?
        from_time = Time.zone.parse(@filters[:from]) rescue nil
        scope = scope.where('created_at >= ?', from_time.beginning_of_day) if from_time
      end

      if @filters[:to].present?
        to_time = Time.zone.parse(@filters[:to]) rescue nil
        scope = scope.where('created_at <= ?', to_time.end_of_day) if to_time
      end

      scope = scope.includes(:user, :whatsapp_message).order(created_at: :desc)
      @llm_conversations = paginate(scope, per_page: 50)

      @tools = LlmConversation.where.not(tool_name: nil).distinct.order(:tool_name).pluck(:tool_name)
      @users_for_filter = User.order(:id).limit(200)
    end

    def show
      @llm_conversation = LlmConversation.includes(:user, :whatsapp_message).find(params[:id])
    end
  end
end
