# frozen_string_literal: true

# Test local du coeur: traitement d'un message vocal (Whisper + LLM + réponse).
#
# Ce script ne dépend PAS d'Unipile pour télécharger l'audio.
# Il utilise le fichier test/voice-note.ogg, l'envoie à Whisper via OpenAI,
# puis passe la transcription au moteur conversationnel.
#
# Exécution:
#   cd /Users/loicboutet/rails/btp_assistant
#   bin/rails runner script/test_voice_note_local.rb
#
# Optionnel:
#   USER_ID=3 CHAT_ID=<unipile_chat_id existant> bin/rails runner script/test_voice_note_local.rb

require "securerandom"

def headline(text)
  puts "\n\n=== #{text} ==="
end

path = Rails.root.join("test/voice-note.ogg")
raise "Fichier audio introuvable: #{path}" unless File.exist?(path)

user = if ENV["USER_ID"].present?
         User.find(ENV["USER_ID"])
       else
         # Prend un user actif si possible
         User.order(:id).detect(&:can_create_documents?) || User.order(:id).first
       end

raise "Aucun user en DB" unless user

# On a besoin d'un chat_id si on veut envoyer une réponse WhatsApp réelle.
# Sinon, le script se contente d'afficher la réponse.
chat_id = ENV["CHAT_ID"].presence || user.unipile_chat_id

headline("User")
puts "user_id=#{user.id} phone=#{user.phone_number} lang=#{user.preferred_language} status=#{user.subscription_status} chat_id=#{chat_id.inspect}"

headline("Transcription Whisper (OpenAI)")
openai = OpenaiClient.new
transcriber = WhatsappBot::AudioTranscriber.new(unipile_client: nil, openai_client: openai)

audio_data = {
  content: File.binread(path),
  content_type: "audio/ogg",
  filename: "voice-note.ogg"
}

result = transcriber.transcribe_audio_data(audio_data, user.preferred_language)
puts "language=#{result[:language]} duration_ms=#{result[:duration_ms]}"
puts "transcription:\n#{result[:transcription]}"

headline("ConversationEngine (LLM + tools)")
engine = WhatsappBot::ConversationEngine.new(user: user, unipile_client: UnipileClient.new, openai_client: openai)
reply = engine.process_message(result[:transcription], detected_language: result[:language])
puts "reply:\n#{reply}"

headline("Envoi WhatsApp (optionnel)")
if chat_id.present?
  begin
    # 1) on loggue un message inbound audio en DB (pour cohérence historique)
    inbound = WhatsappMessage.create!(
      user: user,
      unipile_message_id: "test_audio_in_#{SecureRandom.uuid}",
      unipile_chat_id: chat_id,
      direction: "inbound",
      message_type: "audio",
      content: nil,
      audio_transcription: result[:transcription],
      detected_language: result[:language],
      raw_payload: { "_test" => true, "source" => "script/test_voice_note_local.rb" },
      sent_at: Time.current,
      processed: true
    )
    puts "Inbound audio message saved: id=#{inbound.id}"

    # 2) on envoie la réponse via Unipile
    unipile = UnipileClient.new
    send_res = unipile.send_message(chat_id: chat_id, text: "(TEST VOICE) #{reply}")
    puts "Sent WhatsApp message: #{send_res.inspect}"

  rescue => e
    puts "[WARN] Envoi WhatsApp échoué: #{e.class}: #{e.message}"
  end
else
  puts "Pas de chat_id => pas d'envoi WhatsApp. (Définis CHAT_ID=... ou user.unipile_chat_id)"
end

puts "\nOK"
