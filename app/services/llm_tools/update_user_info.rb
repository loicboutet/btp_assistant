# frozen_string_literal: true

# Tool: Update user's company information
# Used during onboarding or when user wants to change their details
#
module LlmTools
  class UpdateUserInfo < BaseTool
    ALLOWED_FIELDS = %i[company_name siret address vat_number preferred_language].freeze

    def execute(company_name: nil, siret: nil, address: nil, vat_number: nil, preferred_language: nil)
      updates = build_updates(
        company_name: company_name,
        siret: siret,
        address: address,
        vat_number: vat_number,
        preferred_language: preferred_language
      )

      return error("Aucune information à mettre à jour") if updates.empty?

      # Validate fields
      if updates[:siret].present?
        siret_error = validate_siret(updates[:siret])
        return siret_error if siret_error
      end

      if updates[:preferred_language].present?
        unless %w[fr tr].include?(updates[:preferred_language])
          return error("Langue non supportée. Utilisez 'fr' (français) ou 'tr' (turc)", field: "preferred_language")
        end
      end

      # Clean up values
      updates[:siret] = updates[:siret]&.gsub(/\s/, '')
      updates[:company_name] = updates[:company_name]&.strip
      updates[:address] = updates[:address]&.strip
      updates[:vat_number] = updates[:vat_number]&.strip&.upcase

      # Track what changed
      changes = updates.keys.select { |k| user.send(k) != updates[k] }

      if user.update(updates)
        # Check if onboarding should be completed
        check_onboarding_completion!
        
        log_execution("user_info_updated", updated_fields: changes)
        
        success(
          updated_fields: changes,
          company_name: user.company_name,
          siret: user.siret,
          address: user.address,
          vat_number: user.vat_number,
          preferred_language: user.preferred_language,
          onboarding_completed: user.onboarding_completed?,
          message: "Informations mises à jour: #{changes.map(&:to_s).join(', ')}"
        )
      else
        error("Impossible de mettre à jour: #{user.errors.full_messages.join(', ')}")
      end
    end

    private

    def build_updates(**params)
      params.compact.slice(*ALLOWED_FIELDS).reject { |_, v| v.blank? }
    end

    def check_onboarding_completion!
      # Mark onboarding as complete if all required fields are filled
      if user.company_name.present? && user.siret.present? && user.address.present?
        user.complete_onboarding! unless user.onboarding_completed?
      end
    end
  end
end
