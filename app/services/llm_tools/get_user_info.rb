# frozen_string_literal: true

# Tool: Get user's company information
# Used to check what info is filled in or answer account questions
#
module LlmTools
  class GetUserInfo < BaseTool
    def execute
      success(
        phone_number: user.phone_number,
        formatted_phone: user.formatted_phone,
        company_name: user.company_name,
        siret: user.siret,
        address: user.address,
        vat_number: user.vat_number,
        preferred_language: user.preferred_language,
        language_label: language_label(user.preferred_language),
        subscription_status: user.subscription_status,
        subscription_label: subscription_label(user.subscription_status),
        can_create_documents: user.can_create_documents?,
        onboarding_completed: user.onboarding_completed?,
        needs_info: needs_info?,
        missing_fields: missing_fields,
        stats: user_stats
      )
    end

    private

    def language_label(lang)
      { "fr" => "Français", "tr" => "Türkçe" }[lang] || lang
    end

    def subscription_label(status)
      {
        "pending" => "En attente (non payé)",
        "active" => "Actif",
        "past_due" => "Paiement en retard",
        "canceled" => "Annulé"
      }[status] || status
    end

    def needs_info?
      missing_fields.any?
    end

    def missing_fields
      fields = []
      fields << "company_name" if user.company_name.blank?
      fields << "siret" if user.siret.blank?
      fields << "address" if user.address.blank?
      fields
    end

    def user_stats
      {
        total_clients: user.clients.count,
        total_quotes: user.quotes.count,
        total_invoices: user.invoices.count,
        pending_quotes: user.quotes.where(status: %w[draft sent]).count,
        unpaid_invoices: user.invoices.unpaid.count,
        member_since: format_date(user.created_at),
        last_activity: user.last_activity_at ? format_date(user.last_activity_at) : nil
      }
    end
  end
end
