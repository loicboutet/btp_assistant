# frozen_string_literal: true

# Tool: Send a secure signed URL for web access
# Allows users to access their dashboard via browser
#
module LlmTools
  class SendWebLink < BaseTool
    def execute
      # Generate signed URL
      url = SignedUrlService.generate_url(user)
      expiration_minutes = AppSetting.signed_url_expiration_minutes rescue 30

      # Send via WhatsApp
      message = build_message(url, expiration_minutes)
      
      begin
        send_whatsapp_message(message)
        
        log_execution("web_link_sent")
        
        success(
          url_sent: true,
          expiration_minutes: expiration_minutes,
          message: "Lien d'accès envoyé avec succès"
        )
      rescue UnipileClient::Error => e
        error("Impossible d'envoyer le lien: #{e.message}")
      end
    end

    private

    def build_message(url, expiration_minutes)
      if user.french? || user.preferred_language == "fr"
        <<~MSG.strip
          🔗 Voici votre lien d'accès sécurisé:

          #{url}

          ⏱️ Ce lien est valable #{expiration_minutes} minutes.

          Vous pourrez consulter vos devis, factures et clients depuis votre navigateur.
        MSG
      else
        <<~MSG.strip
          🔗 Güvenli erişim bağlantınız:

          #{url}

          ⏱️ Bu bağlantı #{expiration_minutes} dakika geçerlidir.

          Tarayıcınızdan tekliflerinizi, faturalarınızı ve müşterilerinizi görüntüleyebilirsiniz.
        MSG
      end
    end
  end
end
