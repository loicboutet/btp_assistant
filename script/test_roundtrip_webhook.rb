# frozen_string_literal: true

# Test "round-trip" réel via Unipile + webhook :
# 1) Le compte Unipile "client" (CLIENT_UNIPILE_ACCOUNT_ID) envoie des messages au numéro
#    du compte Unipile configuré dans l'app (AppSetting.unipile_account_id).
# 2) L'app reçoit le webhook (sur le compte configuré), crée WhatsappMessage inbound,
#    lance ProcessWhatsappMessageJob, puis répond sur WhatsApp via Unipile.
# 3) Le script attend/poll la réponse en BDD et affiche un résumé.
#
# Pré-requis :
# - ngrok OK, webhook Unipile pointant vers /webhooks/unipile/messages
# - le serveur Rails tourne (bin/dev) car le webhook appelle localhost via ngrok
# - AppSetting.unipile_account_id = le compte qui reçoit (ici l9gI9qdESs6FCN9pqwqOwg)
#
# Exécution:
#   cd /Users/loicboutet/rails/btp_assistant
#   CLIENT_UNIPILE_ACCOUNT_ID=lzXjVQbJS1SxQADQmH-nLQ bin/rails runner script/test_roundtrip_webhook.rb
#
# Optionnel:
#   BOT_ACCOUNT_ID=l9gI9qdESs6FCN9pqwqOwg \
#   BOT_PHONE=+33769363669 \
#   CLIENT_PHONE=+33749368028 \
#   WAIT_SECONDS=15 \
#   bin/rails runner script/test_roundtrip_webhook.rb

require "securerandom"

def headline(text)
  puts "\n\n=== #{text} ==="
end

def e164(phone)
  p = phone.to_s.strip
  p = "+#{p}" unless p.start_with?("+")
  p
end

WAIT_SECONDS = (ENV["WAIT_SECONDS"].presence || 15).to_i

headline("Config")
settings = AppSetting.instance
bot_account_id = ENV["BOT_ACCOUNT_ID"].presence || settings.unipile_account_id
client_account_id = ENV["CLIENT_UNIPILE_ACCOUNT_ID"].presence
raise "CLIENT_UNIPILE_ACCOUNT_ID est obligatoire" if client_account_id.blank?

puts "BOT_ACCOUNT_ID=#{bot_account_id} (AppSetting.unipile_account_id=#{settings.unipile_account_id})"
puts "CLIENT_UNIPILE_ACCOUNT_ID=#{client_account_id}"

# Sécurité: on NE modifie PAS AppSetting.unipile_account_id ici.
raise "AppSetting.unipile_account_id est vide (admin/settings/unipile)" if settings.unipile_account_id.blank?

headline("Unipile account infos")
bot_client = UnipileClient.new(account_id: bot_account_id)
client_client = UnipileClient.new(account_id: client_account_id)

bot_info = bot_client.get_account_info
client_info = client_client.get_account_info

bot_phone = ENV["BOT_PHONE"].presence || bot_info.dig("connection_params", "im", "phone_number") || bot_info["name"]
client_phone = ENV["CLIENT_PHONE"].presence || client_info.dig("connection_params", "im", "phone_number") || client_info["name"]

bot_phone = e164(bot_phone)
client_phone = e164(client_phone)

puts "Bot phone=#{bot_phone} (account=#{bot_account_id})"
puts "Client phone=#{client_phone} (account=#{client_account_id})"

headline("Envoi messages depuis le compte client ")
# On envoie un message au numéro du bot.
# Note: Unipile peut refuser si "recipient cannot be reached" (numéro pas joignable / pas de chat / etc.)
messages = [
  "[TEST #{Time.now.strftime("%H:%M:%S")}] Bonjour, je veux créer un devis pour Dupont.",
  "Ajoute une ligne: pose de carrelage 10 m2 à 50 euros le m2.",
  "Oui vas-y, génère le devis et envoie le PDF."
]

messages.each do |text|
  begin
    resp = client_client.start_new_chat(phone_number: bot_phone, text: text)
    chat_id = resp["chat_id"] || resp.dig("data", "chat_id") || resp["id"]
    puts "Sent from #{client_phone} to #{bot_phone} | chat_id=#{chat_id} | text=#{text.tr("\n", " ")[0,120]}"
  rescue UnipileClient::ApiError => e
    warn "Unipile send failed status=#{e.status} body=#{e.body.inspect}"
    raise
  end
end

headline("Attente du webhook + traitement")
# Le webhook crée l'user sur la base du numéro EXPÉDITEUR (client_phone)
# et crée WhatsappMessage inbound, puis perform_later.

start_t = Time.current
last_seen_id = WhatsappMessage.maximum(:id) || 0

found_in = nil
found_out = nil

while (Time.current - start_t) < WAIT_SECONDS
  # inbound créé après last_seen_id
  found_in = WhatsappMessage.where("id > ?", last_seen_id)
                           .where(direction: "inbound")
                           .order(id: :desc)
                           .find { |m| m.content.to_s.include?("[TEST") }

  if found_in
    user = found_in.user
    found_out = user.whatsapp_messages.where(direction: "outbound")
                     .where("created_at > ?", start_t - 5.seconds)
                     .order(created_at: :desc)
                     .first
  end

  break if found_in && found_out
  sleep 1
end

if found_in.nil?
  puts "⚠️  Aucun message inbound (webhook) détecté en BDD dans les #{WAIT_SECONDS}s."
  puts "Vérifie: ngrok  webhook URL  serveur Rails en marche  logs"
  exit 1
end

user = found_in.user

headline("Résultat")
puts "Inbound: id=#{found_in.id} user_id=#{user.id} phone=#{user.phone_number} chat_id=#{found_in.unipile_chat_id}"
puts "Inbound content: #{found_in.content.to_s.tr("\n", " ")[0, 220]}"

if found_out
  puts "Outbound: id=#{found_out.id} chat_id=#{found_out.unipile_chat_id}"
  puts "Outbound content: #{found_out.content.to_s.tr("\n", " ")[0, 220]}"
else
  puts "⚠️  Pas de réponse outbound détectée (peut-être que le job est encore en cours / queue async)."
  puts "Astuce: regarde les logs Rails, ou augmente WAIT_SECONDS=#{WAIT_SECONDS}."
end

puts "\nStats user: messages=#{user.whatsapp_messages.count} quotes=#{user.quotes.count} invoices=#{user.invoices.count}"
puts "OK"
