# frozen_string_literal: true

# Test complet "webhook réel" + génération/envoi de liens.
#
# Ce script fait un round-trip complet :
# 1) le compte Unipile "client" envoie un message vers le numéro WhatsApp du compte "bot" (celui configuré dans l'app)
# 2) Unipile appelle le webhook Rails (/webhooks/unipile/messages)
# 3) Rails crée WhatsappMessage inbound + lance ProcessWhatsappMessageJob
# 4) Le bot répond via Unipile (WhatsappMessage outbound)
# 5) Le script exécute explicitement les tools "SendWebLink" et "SendPaymentLink" pour afficher tous les liens
#    que l'app sait générer + les envoyer sur WhatsApp.
#
# PRÉ-REQUIS
# - Rails server lancé (bin/dev) et ngrok running
# - webhook Unipile configuré vers:
#     https://<NGROK>.ngrok-free.app/webhooks/unipile/messages
# - AppSetting.unipile_account_id = compte BOT (celui qui reçoit les messages)
# - AppSetting.unipile_api_key + unipile_dsn configurés (sinon pas d'envoi outbound)
# - Stripe configuré (secret + price_id)
#
# EXÉCUTION
#   cd /Users/loicboutet/rails/btp_assistant
#   CLIENT_UNIPILE_ACCOUNT_ID=lzXjVQbJS1SxQADQmH-nLQ \
#   bin/rails runner script/test_webhook_and_links.rb
#
# Options utiles:
#   WAIT_SECONDS=30
#   CLIENT_CHAT_ID=<chat_id coté client vers le bot>   (recommandé si pas trouvé automatiquement)
#   BOT_PHONE=+33769363669 (si tu veux forcer)

require "securerandom"

WAIT_SECONDS = (ENV.fetch("WAIT_SECONDS", "30")).to_i

def headline(text)
  puts "\n\n=== #{text} ==="
end

def e164(phone)
  p = phone.to_s.strip
  p = "+#{p}" unless p.start_with?("+")
  p
end

def assert!(cond, msg)
  raise msg unless cond
end

def find_existing_chat_id(client_unipile:, bot_phone_e164:)
  attendee = "#{bot_phone_e164.delete('+')}@s.whatsapp.net"
  resp = client_unipile.list_chats(limit: 100)
  items = resp["items"] || []

  match = items.find do |ch|
    ch["attendee_provider_id"].to_s == attendee || ch["provider_id"].to_s == attendee
  end

  match&.dig("id")
end

def send_from_client_to_bot!(client_unipile:, bot_phone_e164:, text:)
  # On évite start_new_chat car il peut échouer (recipient cannot be reached) selon le setup.
  chat_id = ENV["CLIENT_CHAT_ID"].presence || find_existing_chat_id(client_unipile: client_unipile, bot_phone_e164: bot_phone_e164)

  unless chat_id.present?
    raise <<~MSG
      Impossible de trouver automatiquement un chat côté CLIENT vers le bot (#{bot_phone_e164}).

      ➜ Solution:
      1) depuis WhatsApp du CLIENT, envoie manuellement un premier message au BOT (pour créer le chat)
      2) relance ce script avec:

         CLIENT_CHAT_ID=<id_du_chat> CLIENT_UNIPILE_ACCOUNT_ID=... bin/rails runner script/test_webhook_and_links.rb

      Tu peux retrouver le chat_id via:
         bin/rails runner 'c=UnipileClient.new(account_id: ENV["CLIENT_UNIPILE_ACCOUNT_ID"]); p c.list_chats(limit: 50)'
    MSG
  end

  client_unipile.send_message(chat_id: chat_id, text: text)
  { chat_id: chat_id }
end

def wait_for_roundtrip!(token:, wait_seconds:)
  start_t = Time.current
  start_max_id = WhatsappMessage.maximum(:id) || 0

  inbound = nil
  outbound = nil

  while (Time.current - start_t) < wait_seconds
    inbound ||= WhatsappMessage.where("id > ?", start_max_id)
                               .where(direction: "inbound")
                               .order(id: :desc)
                               .find { |m| m.content.to_s.include?(token) }

    if inbound
      user = inbound.user
      outbound ||= user.whatsapp_messages.where(direction: "outbound")
                         .order(created_at: :desc)
                         .find { |m| m.created_at >= start_t && m.content.present? }
    end

    break if inbound && outbound
    sleep 1
  end

  { inbound: inbound, outbound: outbound }
end

headline("1) Vérif configuration")
settings = AppSetting.instance

puts "BOT account_id (AppSetting.unipile_account_id)=#{settings.unipile_account_id.inspect}"
puts "unipile_dsn=#{settings.unipile_dsn.inspect}"
puts "unipile_api_key_present?=#{settings.unipile_api_key.present?}"
puts "stripe_configured?=#{settings.stripe_secret_key.present? && settings.stripe_price_id.present?}"
puts "openai_configured?=#{settings.openai_api_key.present?}"

assert!(settings.unipile_account_id.present?, "AppSetting.unipile_account_id (BOT) est vide")
assert!(settings.unipile_dsn.present?, "AppSetting.unipile_dsn est vide")
assert!(settings.unipile_api_key.present?, "AppSetting.unipile_api_key est vide (sans ça le bot ne peut pas répondre)")

client_account_id = ENV["CLIENT_UNIPILE_ACCOUNT_ID"].presence
assert!(client_account_id.present?, "CLIENT_UNIPILE_ACCOUNT_ID est obligatoire")

bot_unipile = UnipileClient.new(account_id: settings.unipile_account_id)
client_unipile = UnipileClient.new(account_id: client_account_id)

bot_info = bot_unipile.get_account_info
client_info = client_unipile.get_account_info

bot_phone = e164(ENV["BOT_PHONE"].presence || bot_info.dig("connection_params", "im", "phone_number") || bot_info["name"])
client_phone = e164(client_info.dig("connection_params", "im", "phone_number") || client_info["name"])

puts "BOT phone=#{bot_phone}"
puts "CLIENT phone=#{client_phone}"

headline("2) Envoi d'un message CLIENT -> BOT (doit déclencher webhook)")
token = "TEST_WEBHOOK_#{SecureRandom.hex(6)}"
text = "[#{token}] Bonjour, test webhook + liens (web + paiement)."

send_meta = send_from_client_to_bot!(client_unipile: client_unipile, bot_phone_e164: bot_phone, text: text)
puts "Message envoyé via chat_id=#{send_meta[:chat_id]}"

headline("3) Attente webhook + réponse bot (poll DB pendant #{WAIT_SECONDS}s)")
res = wait_for_roundtrip!(token: token, wait_seconds: WAIT_SECONDS)

inbound = res[:inbound]
outbound = res[:outbound]

if inbound.nil?
  puts "⚠️  Aucun WhatsappMessage inbound trouvé en BDD avec token=#{token} (dans #{WAIT_SECONDS}s)."
  puts "À vérifier:"
  puts "- webhook URL côté Unipile: https://<ngrok>.ngrok-free.app/webhooks/unipile/messages"
  puts "- ngrok + rails server up"
  puts "- AppSetting.unipile_account_id = #{settings.unipile_account_id}"
  exit 1
end

user = inbound.user
puts "Inbound OK: whatsapp_message_id=#{inbound.id} user_id=#{user.id} phone=#{user.phone_number} chat_id=#{inbound.unipile_chat_id.inspect}"
puts "Inbound content: #{inbound.content.to_s.tr("\n", " ")[0, 220]}"

if outbound
  puts "Outbound OK: whatsapp_message_id=#{outbound.id} chat_id=#{outbound.unipile_chat_id.inspect}"
  puts "Outbound content: #{outbound.content.to_s.tr("\n", " ")[0, 220]}"
else
  puts "⚠️  Pas de réponse outbound détectée en BDD (job async encore en cours ?)."
end

headline("4) Liens générés par l'app + envoi WhatsApp (tools)")

# 4.1 Lien web (SignedUrlService)
web_url = SignedUrlService.generate_url(user)
puts "Lien web (signed URL): #{web_url}"

# 4.2 Tool: SendWebLink (envoie sur WhatsApp)
begin
  r = LlmTools::SendWebLink.new(user: user, unipile_client: bot_unipile).execute
  puts "SendWebLink => #{r.inspect}"
rescue => e
  puts "SendWebLink erreur: #{e.class}: #{e.message}"
end

# 4.3 Tool: SendPaymentLink (envoie sur WhatsApp + retourne payment_url)
# On force le user en pending sinon le tool ne renverra pas de lien (cas abonnement actif).
previous_status = user.subscription_status
begin
  user.update!(subscription_status: "pending") unless user.pending?
  r = LlmTools::SendPaymentLink.new(user: user, unipile_client: bot_unipile).execute
  puts "SendPaymentLink => #{r.inspect}"
ensure
  user.update!(subscription_status: previous_status) if previous_status.present? && user.subscription_status != previous_status
end

# 4.4 Bonus: afficher les URLs Stripe sans envoyer (checkout + billing portal)
if settings.stripe_secret_key.present? && settings.stripe_price_id.present?
  stripe = StripeService.new

  begin
    base = web_url.split("/u/").first
    checkout = stripe.create_checkout_session(
      user: user,
      success_url: "#{base}/payment/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{base}/payment/canceled"
    )
    puts "Stripe Checkout URL: #{checkout.url}"
  rescue => e
    puts "Stripe checkout erreur: #{e.class}: #{e.message}"
  end

  begin
    stripe.ensure_customer(user)
    portal = stripe.create_portal_session(user: user, return_url: "#{web_url.split("/u/").first}/dashboard")
    puts "Stripe Billing Portal URL: #{portal.url}"
  rescue => e
    puts "Stripe billing portal erreur: #{e.class}: #{e.message}"
  end
end

headline("Résumé")
puts "User(#{user.id}) phone=#{user.phone_number} subscription_status=#{user.subscription_status}"
puts "Messages user=#{user.whatsapp_messages.count} | Quotes=#{user.quotes.count} | Invoices=#{user.invoices.count}"
puts "OK"
