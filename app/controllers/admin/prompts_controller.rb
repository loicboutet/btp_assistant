# frozen_string_literal: true

module Admin
  class PromptsController < Admin::BaseController
    before_action :set_prompt, only: %i[edit update test]

    def index
      @prompts = LlmPrompt.by_name
    end

    def edit
    end

    def update
      if @prompt.update(prompt_params)
        log_admin_action('prompt_updated', "Prompt #{@prompt.name} updated", prompt_id: @prompt.id, name: @prompt.name, version: @prompt.version)
        redirect_to admin_prompts_path, notice: 'Prompt mis à jour.'
      else
        flash.now[:alert] = @prompt.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    # POST /admin/prompts/:id/test
    # Minimal "test prompt" mode: send system prompt + user input to OpenAI (no tools)
    def test
      input = params[:input].presence || "Bonjour, peux-tu me répondre brièvement ?"

      client = OpenaiClient.new
      response = client.chat(
        messages: [
          { role: 'system', content: @prompt.prompt_text },
          { role: 'user', content: input }
        ],
        temperature: (params[:temperature].presence || 0.2).to_f
      )

      result_text = response[:content].to_s

      log_admin_action('prompt_tested', "Prompt #{@prompt.name} tested", prompt_id: @prompt.id, name: @prompt.name)

      respond_to do |format|
        format.json { render json: { success: true, output: result_text } }
        format.html do
          @test_input = input
          @test_output = result_text
          flash.now[:notice] = 'Test exécuté.'
          render :edit
        end
      end
    rescue OpenaiClient::ConfigurationError => e
      respond_to do |format|
        format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
        format.html do
          flash.now[:alert] = "OpenAI non configuré : #{e.message}"
          render :edit, status: :unprocessable_entity
        end
      end
    rescue OpenaiClient::ApiError => e
      respond_to do |format|
        format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
        format.html do
          flash.now[:alert] = "Erreur OpenAI : #{e.message}"
          render :edit, status: :unprocessable_entity
        end
      end
    rescue StandardError => e
      respond_to do |format|
        format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
        format.html do
          flash.now[:alert] = "Erreur : #{e.message}"
          render :edit, status: :unprocessable_entity
        end
      end
    end

    private

    def set_prompt
      @prompt = LlmPrompt.find(params[:id])
    end

    def prompt_params
      params.require(:llm_prompt).permit(:description, :prompt_text, :is_active)
    end
  end
end
