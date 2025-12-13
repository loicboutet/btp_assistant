# frozen_string_literal: true

# Conversation Engine for the WhatsApp Bot
# Processes user messages through GPT-4 with tool calling
# Implements Option B: Execute one tool at a time, send result back to LLM
#
# Usage:
#   engine = WhatsappBot::ConversationEngine.new(user: user)
#   response = engine.process_message("Crée un devis pour Dupont")
#   # => "Je ne trouve pas de client Dupont. Voulez-vous le créer?"
#
module WhatsappBot
  class ConversationEngine
    MAX_TOOL_ITERATIONS = 5
    CONTEXT_MESSAGES_LIMIT = 15
    CONTEXT_HOURS_LIMIT = 2

    attr_reader :user

    def initialize(user:, unipile_client: nil, openai_client: nil)
      @user = user
      @_unipile_client = unipile_client
      @_openai_client = openai_client
      @tool_calls_made = []
    end

    # Lazy-load clients
    def unipile_client
      @_unipile_client ||= UnipileClient.new
    end

    def openai_client
      @_openai_client ||= OpenaiClient.new
    end

    def tool_executor
      @_tool_executor ||= LlmTools::Executor.new(user: user, unipile_client: unipile_client)
    end

    # Main entry point - process a message and return response text
    # @param message_text [String] The user's message
    # @param detected_language [String, nil] Language detected from audio transcription
    # @return [String] The response text to send back
    def process_message(message_text, detected_language: nil)
      return default_error_response if message_text.blank?

      # Update user's preferred language if detected
      update_language_preference(detected_language) if detected_language.present?

      # Build conversation context
      messages = build_messages(message_text)

      # Run the conversation loop
      response_text = run_conversation_loop(messages)

      response_text
    rescue OpenaiClient::ConfigurationError => e
      Rails.logger.error "[ConversationEngine] OpenAI not configured: #{e.message}"
      configuration_error_response
    rescue OpenaiClient::RateLimitError => e
      Rails.logger.error "[ConversationEngine] Rate limit: #{e.message}"
      rate_limit_response
    rescue StandardError => e
      Rails.logger.error "[ConversationEngine] Error: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      default_error_response
    end

    private

    # Build the full message array including system prompt and context
    def build_messages(current_message)
      messages = []
      
      # Add system prompt
      messages << { role: "system", content: system_prompt }
      
      # Add conversation context (recent messages)
      context = build_context
      messages.concat(context)
      
      # Add current message
      messages << { role: "user", content: current_message }
      
      messages
    end

    # Get recent messages for context
    def build_context
      context_limit = AppSetting.conversation_context_messages rescue CONTEXT_MESSAGES_LIMIT
      context_hours = AppSetting.conversation_context_hours rescue CONTEXT_HOURS_LIMIT

      recent_messages = WhatsappMessage.context_for_user(user, limit: context_limit, hours: context_hours)
      
      recent_messages.filter_map do |msg|
        # Skip messages without content
        content = msg.audio? && msg.audio_transcription.present? ? msg.audio_transcription : msg.content
        next if content.blank?

        {
          role: msg.inbound? ? "user" : "assistant",
          content: content
        }
      end
    end

    # Build the system prompt with user context
    def system_prompt
      # Try to get from database first
      prompt_record = LlmPrompt.find_by(name: "system_prompt", is_active: true)
      prompt_template = prompt_record&.prompt_text || default_system_prompt

      # Replace placeholders
      prompt_template
        .gsub("{{company_name}}", user.company_name || "Non renseigné")
        .gsub("{{siret}}", user.siret || "Non renseigné")
        .gsub("{{address}}", user.address || "Non renseignée")
        .gsub("{{subscription_status}}", subscription_status_label)
        .gsub("{{can_create_documents}}", user.can_create_documents?.to_s)
        .gsub("{{preferred_language}}", user.preferred_language)
    end

    def default_system_prompt
      <<~PROMPT
        Tu es un assistant intelligent pour artisans du BTP (bâtiment et travaux publics).
        Tu aides les utilisateurs à créer des devis et factures via WhatsApp.

        Langue: Réponds dans la langue utilisée par l'utilisateur (français ou turc).
        Si l'utilisateur parle français, réponds en français.
        Si l'utilisateur parle turc, réponds en turc.

        Contexte utilisateur:
        - Entreprise: {{company_name}}
        - SIRET: {{siret}}
        - Adresse: {{address}}
        - Statut abonnement: {{subscription_status}}
        - Peut créer des documents: {{can_create_documents}}

        Règles importantes:
        1. Si l'utilisateur n'a pas d'abonnement actif (pending/canceled), collecte ses informations (nom entreprise, SIRET, adresse) puis envoie un lien de paiement avec send_payment_link.
        2. Pour créer un devis ou une facture, vérifie d'abord si le client existe avec search_clients.
        3. Si le client n'existe pas, demande les informations nécessaires et crée-le avec create_client.
        4. Les montants sont en euros (€), TVA par défaut 20%.
        5. Après création d'un document, il est automatiquement envoyé.
        6. Pour l'accès web, utilise send_web_link.

        Tu dois être concis, professionnel et amical. Utilise des emojis avec modération (1-2 par message maximum).
        Ne répète pas les informations déjà données. Va droit au but.

        Si tu ne comprends pas la demande, demande des clarifications poliment.
      PROMPT
    end

    def subscription_status_label
      {
        "pending" => "En attente (non payé)",
        "active" => "Actif",
        "past_due" => "Paiement en retard",
        "canceled" => "Annulé"
      }[user.subscription_status] || user.subscription_status
    end

    # Run the conversation loop with tool calling
    def run_conversation_loop(messages)
      iterations = 0
      
      loop do
        iterations += 1
        
        if iterations > MAX_TOOL_ITERATIONS
          Rails.logger.warn "[ConversationEngine] Max tool iterations reached"
          return too_many_iterations_response
        end

        # Call GPT-4 with tools
        start_time = Time.current
        response = openai_client.chat_with_tools(
          messages: messages,
          tools: LlmTools::ToolDefinitions::TOOLS
        )
        
        # Log the conversation
        log_llm_conversation(messages, response, start_time)

        # Check if we have a tool call
        if response[:tool_calls].present?
          tool_call = response[:tool_calls].first
          tool_name = tool_call.dig(:function, :name)
          tool_args = tool_call.dig(:function, :arguments) || {}
          
          Rails.logger.info "[ConversationEngine] Tool call: #{tool_name}"
          
          # Execute the tool
          tool_result = tool_executor.execute(
            tool_name: tool_name,
            arguments: tool_args
          )
          
          @tool_calls_made << { name: tool_name, args: tool_args, result: tool_result }
          
          # Add assistant message with tool call
          messages << {
            role: "assistant",
            content: nil,
            tool_calls: [
              {
                id: tool_call[:id],
                type: "function",
                function: {
                  name: tool_name,
                  arguments: tool_args.to_json
                }
              }
            ]
          }
          
          # Add tool result
          messages << {
            role: "tool",
            tool_call_id: tool_call[:id],
            content: tool_result.to_json
          }
          
          # Continue the loop to get the next response
          next
        end

        # No tool call, return the text response
        return response[:content] || default_error_response
      end
    end

    def log_llm_conversation(messages, response, start_time)
      duration_ms = ((Time.current - start_time) * 1000).to_i
      
      tool_call = response[:tool_calls]&.first
      
      LlmConversation.create!(
        user: user,
        messages_payload: messages,
        response_payload: response,
        tool_name: tool_call&.dig(:function, :name),
        tool_arguments: tool_call&.dig(:function, :arguments),
        prompt_tokens: response.dig(:usage, :prompt_tokens),
        completion_tokens: response.dig(:usage, :completion_tokens),
        total_tokens: response.dig(:usage, :total_tokens),
        model: response[:model],
        duration_ms: duration_ms
      )
    rescue StandardError => e
      Rails.logger.error "[ConversationEngine] Failed to log conversation: #{e.message}"
    end

    def update_language_preference(detected_language)
      return unless %w[fr tr].include?(detected_language)
      return if user.preferred_language == detected_language
      
      user.update(preferred_language: detected_language)
      Rails.logger.info "[ConversationEngine] Updated language preference to #{detected_language}"
    end

    # Error response messages
    def default_error_response
      if user.turkish?
        "Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin."
      else
        "Désolé, une erreur s'est produite. Veuillez réessayer."
      end
    end

    def configuration_error_response
      if user.turkish?
        "Sistem şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin."
      else
        "Le système n'est pas disponible actuellement. Veuillez réessayer plus tard."
      end
    end

    def rate_limit_response
      if user.turkish?
        "Çok fazla istek gönderdiniz. Lütfen birkaç dakika bekleyin."
      else
        "Vous avez envoyé trop de messages. Veuillez patienter quelques minutes."
      end
    end

    def too_many_iterations_response
      if user.turkish?
        "Bu işlem çok karmaşık görünüyor. Lütfen isteğinizi daha basit bir şekilde ifade edin."
      else
        "Cette demande semble trop complexe. Veuillez reformuler votre demande de manière plus simple."
      end
    end
  end
end
