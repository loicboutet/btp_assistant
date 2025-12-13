# frozen_string_literal: true

module Admin
  class WhatsappMessagesController < Admin::BaseController
    def index
      @filters = {
        q: params[:q].to_s.strip.presence,
        user_id: params[:user_id].to_s.strip.presence,
        direction: params[:direction].to_s.strip.presence,
        message_type: params[:message_type].to_s.strip.presence,
        processed: params[:processed].to_s.strip.presence,
        with_errors: params[:with_errors].to_s.strip.presence,
        from: params[:from].to_s.strip.presence,
        to: params[:to].to_s.strip.presence
      }

      scope = WhatsappMessage.all

      scope = scope.where(user_id: @filters[:user_id]) if @filters[:user_id].present?
      scope = scope.where(direction: @filters[:direction]) if @filters[:direction].present?
      scope = scope.where(message_type: @filters[:message_type]) if @filters[:message_type].present?

      if @filters[:processed].present?
        processed = ActiveModel::Type::Boolean.new.cast(@filters[:processed])
        scope = scope.where(processed: processed)
      end

      scope = scope.with_errors if ActiveModel::Type::Boolean.new.cast(@filters[:with_errors])

      if @filters[:from].present?
        from_time = Time.zone.parse(@filters[:from]) rescue nil
        scope = scope.where('created_at >= ?', from_time.beginning_of_day) if from_time
      end

      if @filters[:to].present?
        to_time = Time.zone.parse(@filters[:to]) rescue nil
        scope = scope.where('created_at <= ?', to_time.end_of_day) if to_time
      end

      if @filters[:q].present?
        q = "%#{@filters[:q]}%"
        scope = scope.where('content LIKE ? OR audio_transcription LIKE ? OR unipile_message_id LIKE ?', q, q, q)
      end

      scope = scope.includes(:user, :llm_conversation).order(created_at: :desc)
      @whatsapp_messages = paginate(scope, per_page: 50)

      @directions = %w[inbound outbound]
      @message_types = %w[text audio image document video]
      @users_for_filter = User.order(:id).limit(200)
    end

    def show
      @whatsapp_message = WhatsappMessage.includes(:user, :llm_conversation).find(params[:id])
    end
  end
end
