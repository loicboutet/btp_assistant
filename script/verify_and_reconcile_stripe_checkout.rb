# frozen_string_literal: true

# Vérifie une Checkout Session Stripe et (optionnel) réconcilie la BDD sans webhook.
#
# Usage:
#   cd /Users/loicboutet/rails/btp_assistant
#   SESSION_ID=cs_test_... bin/rails runner script/verify_and_reconcile_stripe_checkout.rb
#
# Pour appliquer la mise à jour en DB (DANGEREUX) :
#   SESSION_ID=cs_test_... APPLY=1 bin/rails runner script/verify_and_reconcile_stripe_checkout.rb

session_id = ENV["SESSION_ID"].to_s.strip
raise "SESSION_ID manquant" if session_id.empty?

apply = ENV["APPLY"].to_s == "1"

puts "Stripe session_id=#{session_id} apply=#{apply}"

# Initialise Stripe (clé depuis AppSetting)
StripeService.new

session = Stripe::Checkout::Session.retrieve(
  {
    id: session_id,
    expand: ["subscription", "customer"]
  }
)

puts "\n--- Checkout Session ---"
puts "status=#{session.status.inspect} payment_status=#{session.payment_status.inspect} mode=#{session.mode.inspect}"
puts "customer=#{session.customer.respond_to?(:id) ? session.customer.id : session.customer.inspect}"
puts "subscription=#{session.subscription.respond_to?(:id) ? session.subscription.id : session.subscription.inspect}"
puts "metadata=#{session.metadata.to_h.inspect}"

paid = (session.payment_status.to_s == "paid") || (session.status.to_s == "complete")

unless paid
  puts "\n❌ La session n'est pas payée/complète => on n'applique rien."
  exit 0
end

# Trouver le user
user = nil
meta_user_id = session.metadata.to_h["user_id"]

if meta_user_id.present?
  user = User.find_by(id: meta_user_id)
end

if user.nil?
  # fallback par customer
  cust_id = session.customer.respond_to?(:id) ? session.customer.id : session.customer
  user = User.find_by(stripe_customer_id: cust_id) if cust_id.present?
end

if user.nil?
  puts "\n⚠️ Aucun user trouvé pour cette session."
  puts "- metadata.user_id=#{meta_user_id.inspect}"
  puts "- customer=#{session.customer.inspect}"
  exit 1
end

puts "\n--- User ---"
puts "user_id=#{user.id} phone=#{user.phone_number} subscription_status=#{user.subscription_status} stripe_customer_id=#{user.stripe_customer_id.inspect}"

subscription = session.subscription
subscription_id = subscription.respond_to?(:id) ? subscription.id : subscription

puts "\n--- Décision ---"
puts "✅ Paiement confirmé côté Stripe."
puts "- user à activer: #{user.id}"
puts "- stripe_customer_id: #{session.customer.respond_to?(:id) ? session.customer.id : session.customer}"
puts "- stripe_subscription_id: #{subscription_id.inspect}"

unless apply
  puts "\nMode DRY-RUN => aucune écriture DB. Relance avec APPLY=1 pour appliquer."
  exit 0
end

ActiveRecord::Base.transaction do
  cust_id = session.customer.respond_to?(:id) ? session.customer.id : session.customer
  user.update!(
    subscription_status: "active",
    stripe_customer_id: (user.stripe_customer_id.presence || cust_id)
  )

  if subscription.respond_to?(:status)
    # Création / mise à jour du record Subscription local
    rec = user.subscriptions.find_or_initialize_by(stripe_subscription_id: subscription.id)

    price_id = nil
    if subscription.items.respond_to?(:data)
      first_item = subscription.items.data.first
      price_id = first_item&.price&.id if first_item&.respond_to?(:price)
    end

    rec.update!(
      stripe_price_id: price_id,
      status: subscription.status,
      current_period_start: (subscription.current_period_start ? Time.at(subscription.current_period_start) : nil),
      current_period_end: (subscription.current_period_end ? Time.at(subscription.current_period_end) : nil),
      cancel_at_period_end: subscription.cancel_at_period_end || false
    )
  end
end

puts "\n✅ DB mise à jour : user.subscription_status=active"
