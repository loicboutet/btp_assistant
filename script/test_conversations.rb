# frozen_string_literal: true

# Script de test end-to-end (local) :
# - utilise la BDD (User/Client/Quote/Invoice/WhatsappMessage)
# - utilise Unipile pour envoyer de vrais messages sortants (réponses du bot + PDFs)
# - simule des messages entrants (inbound) en créant des WhatsappMessage puis en exécutant ProcessWhatsappMessageJob
#   (=> déclenche OpenAI + tools + génération PDF + envoi WhatsApp via Unipile)
#
# IMPORTANT
# - Avec UN SEUL compte Unipile, tu ne peux pas "envoyer en tant que le client" (inbound) :
#   Unipile envoie en tant que le numéro WhatsApp connecté.
#   Pour simuler l'inbound automatiquement on le fait donc via la BDD + job.
#   Si tu veux tester le vrai webhook inbound, envoie un message manuellement depuis ton téléphone.
#
# Exécution :
#   cd /Users/loicboutet/rails/btp_assistant
#   bin/rails runner script/test_conversations.rb
#
# Variables optionnelles :
#   UNIPILE_ACCOUNT_ID=lzXjVQbJS1SxQADQmH-nLQ \
#   UNIPILE_CHAT_ID=gRcx6GncWN-T_5mBJU_e0Q \
#   ARTISAN_PHONE=+33612345678 \
#   NGROK_HOST=074da289dffc.ngrok-free.app \
#   bin/rails runner script/test_conversations.rb

require "securerandom"

def headline(text)
  puts "\n\n=== #{text} ==="
end

def pick_chat_id!(unipile_client:, preferred_chat_id: nil)
  resp = unipile_client.list_chats(limit: 50)
  items = resp["items"] || []

  raise "Aucun chat trouvé sur ce compte Unipile" if items.empty?

  if preferred_chat_id.present?
    chat = items.find { |c| c["id"].to_s == preferred_chat_id.to_s }
    raise "UNIPILE_CHAT_ID=#{preferred_chat_id} introuvable dans les chats" unless chat
    return chat["id"]
  end

  # Par défaut: on prend le premier chat (le plus récent) pour tester l'envoi
  items.first["id"]
end

def simulate_inbound_and_process!(user:, chat_id:, text:)
  msg = WhatsappMessage.create!(
    user: user,
    unipile_message_id: "test_in_#{SecureRandom.uuid}",
    unipile_chat_id: chat_id,
    direction: "inbound",
    message_type: "text",
    content: text,
    raw_payload: {
      "_test" => true,
      "source" => "script/test_conversations.rb",
      "chat_id" => chat_id,
      "text" => text
    },
    sent_at: Time.current,
    processed: false
  )

  puts "\n[IN ] ##{msg.id} #{text}"

  ProcessWhatsappMessageJob.perform_now(msg.id)

  out = user.whatsapp_messages.where(direction: "outbound").order(created_at: :desc).first
  if out
    puts "[OUT] ##{out.id} #{out.content.to_s.tr("\n", " ")[0, 220]}"
  else
    puts "[OUT] (aucune réponse outbound trouvée en BDD)"
  end

  msg
end

# -----------------------------------------------------------------------------
# Paramètres
# -----------------------------------------------------------------------------
account_id = ENV["UNIPILE_ACCOUNT_ID"].presence || "lzXjVQbJS1SxQADQmH-nLQ"
preferred_chat_id = ENV["UNIPILE_CHAT_ID"].presence
artisan_phone = ENV["ARTISAN_PHONE"].presence || User.first&.phone_number || "+33612345678"

headline("Configuration")
puts "UNIPILE_ACCOUNT_ID=#{account_id}"
puts "UNIPILE_CHAT_ID=#{preferred_chat_id || '(auto)'}"
puts "ARTISAN_PHONE=#{artisan_phone}"

# S'assure que l'app est bien config pour Unipile (important pour les webhooks + jobs)
setting = AppSetting.instance
setting.update!(unipile_account_id: account_id) if setting.unipile_account_id != account_id

# -----------------------------------------------------------------------------
# Smoke tests configuration services
# -----------------------------------------------------------------------------
headline("Smoke tests (config)")
puts "Unipile configured? #{AppSetting.instance.unipile_dsn.present? && AppSetting.instance.unipile_api_key.present? && AppSetting.instance.unipile_account_id.present?}"
puts "OpenAI configured?  #{AppSetting.instance.openai_api_key.present?}"
puts "Stripe configured?  #{AppSetting.instance.stripe_secret_key.present? && AppSetting.instance.stripe_price_id.present?}"

# -----------------------------------------------------------------------------
# User (artisan)
# -----------------------------------------------------------------------------
headline("User / BDD")
user = User.find_or_create_by!(phone_number: artisan_phone) do |u|
  u.subscription_status = "active"
  u.preferred_language = "fr"
end

user.update!(
  subscription_status: "active",
  preferred_language: "fr",
  company_name: user.company_name.presence || "BTP Test (Local)",
  siret: user.siret.presence || "12345678901234",
  address: user.address.presence || "1 rue de la Démo, 75000 Paris"
)

puts "User id=#{user.id} phone=#{user.phone_number} status=#{user.subscription_status}"

# -----------------------------------------------------------------------------
# Unipile: choisir un chat existant pour pouvoir envoyer de vraies réponses
# -----------------------------------------------------------------------------
headline("Unipile / Chat (existant)")
unipile = UnipileClient.new(account_id: account_id)
account_info = unipile.get_account_info
puts "Unipile account type=#{account_info['type']} id=#{account_info['id']} name=#{account_info['name']}"

chat_id = pick_chat_id!(unipile_client: unipile, preferred_chat_id: preferred_chat_id)

user.update!(unipile_chat_id: chat_id) if user.unipile_chat_id != chat_id
puts "Chat_id=#{chat_id} (sauvé sur user.unipile_chat_id)"

begin
  unipile.send_message(chat_id: chat_id, text: "✅ Début des tests automatisés (OpenAI + outils + PDF).")
rescue StandardError => e
  puts "[WARN] Impossible d'envoyer le message de démarrage via Unipile: #{e.class}: #{e.message}"
end

# -----------------------------------------------------------------------------
# Données BDD utiles (clients)
# -----------------------------------------------------------------------------
headline("Seed minimal (Client)")
client = user.clients.first || user.clients.create!(
  name: "Dupont",
  address: "10 avenue des Tests, 75000 Paris",
  contact_phone: "+33700000000",
  created_via: "script"
)
puts "Client id=#{client.id} name=#{client.name}"

# -----------------------------------------------------------------------------
# Scénarios de conversation
# -----------------------------------------------------------------------------
headline("Scénarios")

# Note: le LLM demande souvent une confirmation avant de créer un devis/facture.
# Donc on envoie explicitement une confirmation derrière.
scenarios = [
  "Bonjour, tu peux me rappeler mes infos ?",
  "Liste mes derniers devis",

  "Crée un devis pour #{client.name} : pose de carrelage 10 m2 à 50 € le m2",
  "Oui vas-y, crée le devis et envoie le PDF",

  "Crée une facture pour #{client.name} : pose de carrelage 10 m2 à 50 € le m2",
  "Oui vas-y, crée la facture et envoie le PDF",

  "Envoie-moi le lien web pour consulter mes documents"
]

scenarios.each_with_index do |text, idx|
  headline("Message #{idx + 1}/#{scenarios.size}")
  simulate_inbound_and_process!(user: user, chat_id: chat_id, text: text)
end

headline("Résumé")
puts "WhatsappMessages total=#{WhatsappMessage.count} (user=#{user.whatsapp_messages.count})"
puts "Quotes user=#{user.quotes.count} | Invoices user=#{user.invoices.count} | Clients user=#{user.clients.count}"
puts "LLM conversations user=#{user.llm_conversations.count}"
puts "OK"
