# frozen_string_literal: true

require "test_helper"

class LlmTools::SendPaymentLinkTest < ActiveSupport::TestCase
  setup do
    @pending_user = users(:pending_user)
    @pending_user.update!(unipile_chat_id: "chat_pending_test")
    
    @active_user = users(:active_user)
    @active_user.update!(unipile_chat_id: "chat_active_test")
    
    @canceled_user = users(:canceled_user)
    @canceled_user.update!(unipile_chat_id: "chat_canceled_test")
    
    @turkish_user = users(:turkish_user)
    @turkish_user.update!(unipile_chat_id: "chat_turkish_test", subscription_status: 'pending')

    # Setup Stripe configuration
    setup_stripe_config

    # Mock UnipileClient
    @mock_unipile = mock('UnipileClient')
  end

  # ========================================
  # Already Active User Tests
  # ========================================

  test "returns already_active for active users in French" do
    tool = LlmTools::SendPaymentLink.new(user: @active_user, unipile_client: @mock_unipile)
    result = tool.execute

    assert result[:success]
    assert result[:data][:already_active]
    assert_includes result[:data][:message], "déjà un abonnement actif"
  end

  test "returns already_active for active users in Turkish" do
    @active_user.update!(preferred_language: 'tr')
    tool = LlmTools::SendPaymentLink.new(user: @active_user, unipile_client: @mock_unipile)
    result = tool.execute

    assert result[:success]
    assert result[:data][:already_active]
    assert_includes result[:data][:message], "aktif bir aboneliğiniz var"
  end

  # ========================================
  # Successful Payment Link Tests
  # ========================================

  test "sends payment link for pending user" do
    stub_stripe_customer_create
    stub_stripe_checkout_session_create

    @mock_unipile.expects(:send_message).with(
      chat_id: "chat_pending_test",
      text: regexp_matches(/Lien de paiement/)
    ).returns({ success: true })

    tool = LlmTools::SendPaymentLink.new(user: @pending_user, unipile_client: @mock_unipile)
    result = tool.execute

    assert result[:success]
    assert_equal "cs_test_session_123", result[:data][:checkout_session_id]
    assert_equal "https://checkout.stripe.com/pay/cs_test_session_123", result[:data][:payment_url]
  end

  test "sends payment link for canceled user" do
    @canceled_user.update!(stripe_customer_id: "cus_canceled_existing")
    stub_stripe_checkout_session_create

    @mock_unipile.expects(:send_message).with(
      chat_id: "chat_canceled_test",
      text: regexp_matches(/Lien de paiement/)
    ).returns({ success: true })

    tool = LlmTools::SendPaymentLink.new(user: @canceled_user, unipile_client: @mock_unipile)
    result = tool.execute

    assert result[:success]
    assert_equal "cs_test_session_123", result[:data][:checkout_session_id]
  end

  test "sends payment link in Turkish for Turkish user" do
    stub_stripe_customer_create
    stub_stripe_checkout_session_create

    @mock_unipile.expects(:send_message).with(
      chat_id: "chat_turkish_test",
      text: regexp_matches(/abonelik ödeme bağlantısı/)
    ).returns({ success: true })

    tool = LlmTools::SendPaymentLink.new(user: @turkish_user, unipile_client: @mock_unipile)
    result = tool.execute

    assert result[:success]
    assert_includes result[:data][:message], "gönderildi"
  end

  # ========================================
  # Message Content Tests
  # ========================================

  test "French message includes price and benefits" do
    stub_stripe_customer_create
    stub_stripe_checkout_session_create

    captured_message = nil
    @mock_unipile.expects(:send_message).with { |args|
      captured_message = args[:text]
      true
    }.returns({ success: true })

    tool = LlmTools::SendPaymentLink.new(user: @pending_user, unipile_client: @mock_unipile)
    tool.execute

    assert_includes captured_message, "29,90 €"
    assert_includes captured_message, "devis et factures illimités"
    assert_includes captured_message, "checkout.stripe.com"
  end

  test "Turkish message includes price and benefits" do
    stub_stripe_customer_create
    stub_stripe_checkout_session_create

    captured_message = nil
    @mock_unipile.expects(:send_message).with { |args|
      captured_message = args[:text]
      true
    }.returns({ success: true })

    tool = LlmTools::SendPaymentLink.new(user: @turkish_user, unipile_client: @mock_unipile)
    tool.execute

    assert_includes captured_message, "29,90 €"
    assert_includes captured_message, "teklif ve fatura"
    assert_includes captured_message, "checkout.stripe.com"
  end

  # ========================================
  # Error Handling Tests
  # ========================================

  test "returns error when Stripe not configured" do
    AppSetting.instance.update!(stripe_secret_key: nil)

    tool = LlmTools::SendPaymentLink.new(user: @pending_user, unipile_client: @mock_unipile)
    result = tool.execute

    refute result[:success]
    assert_includes result[:error], "paiement n'est pas configuré"
  end

  test "returns Turkish error when Stripe not configured for Turkish user" do
    AppSetting.instance.update!(stripe_secret_key: nil)

    tool = LlmTools::SendPaymentLink.new(user: @turkish_user, unipile_client: @mock_unipile)
    result = tool.execute

    refute result[:success]
    assert_includes result[:error], "yapılandırılmamış"
  end

  test "returns error when Stripe API fails" do
    stub_stripe_customer_create
    stub_request(:post, "https://api.stripe.com/v1/checkout/sessions")
      .to_return(status: 400, body: { error: { message: "Invalid price" } }.to_json)

    tool = LlmTools::SendPaymentLink.new(user: @pending_user, unipile_client: @mock_unipile)
    result = tool.execute

    refute result[:success]
    assert_includes result[:error], "Impossible de générer"
  end

  # ========================================
  # Logging Tests
  # ========================================

  test "logs successful payment link send" do
    stub_stripe_customer_create
    stub_stripe_checkout_session_create
    @mock_unipile.stubs(:send_message).returns({ success: true })

    tool = LlmTools::SendPaymentLink.new(user: @pending_user, unipile_client: @mock_unipile)
    
    assert_difference 'SystemLog.count', 1 do
      tool.execute
    end

    log = SystemLog.last
    assert_equal 'tool_payment_link_sent', log.event
  end

  private

  def setup_stripe_config
    AppSetting.instance.update!(
      stripe_secret_key: "sk_test_stripe_key_123",
      stripe_price_id: "price_test_monthly_2990",
      stripe_webhook_secret: "whsec_test_webhook_secret_123"
    )
  end

  def stub_stripe_customer_create
    stub_request(:post, "https://api.stripe.com/v1/customers")
      .to_return(status: 200, body: {
        id: "cus_test_new_123",
        object: "customer"
      }.to_json)
  end

  def stub_stripe_checkout_session_create
    stub_request(:post, "https://api.stripe.com/v1/checkout/sessions")
      .to_return(status: 200, body: {
        id: "cs_test_session_123",
        url: "https://checkout.stripe.com/pay/cs_test_session_123",
        object: "checkout.session"
      }.to_json)
  end
end
