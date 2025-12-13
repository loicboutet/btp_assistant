# frozen_string_literal: true

require "test_helper"

class LlmTools::CreateQuoteTest < ActiveSupport::TestCase
  setup do
    @user = users(:active_user)
    @client = @user.clients.create!(name: "Test Client", address: "123 Test St")
    
    # Setup Unipile mock
    AppSetting.instance.update!(
      unipile_dsn: "https://api.unipile.com:13211",
      unipile_api_key: "test-key",
      unipile_account_id: "test-account"
    )
    
    @user.update!(unipile_chat_id: "chat_123")
    
    stub_request(:post, %r{api.unipile.com.*/messages})
      .to_return(status: 200, body: { message_id: "msg_123" }.to_json)
    
    @tool = LlmTools::CreateQuote.new(user: @user)
  end

  test "creates quote with single item" do
    items = [
      { description: "Travaux de maçonnerie", quantity: 10, unit: "m²", unit_price: 50 }
    ]
    
    result = @tool.execute(client_id: @client.id, items: items)
    
    assert result[:success]
    assert result[:data][:quote_id].present?
    assert_match(/DEVIS-\d{4}-\d{4}/, result[:data][:quote_number])
    assert_equal "Test Client", result[:data][:client_name]
    assert_equal 1, result[:data][:items_count]
    
    quote = Quote.find(result[:data][:quote_id])
    assert_equal 500.0, quote.subtotal_amount
    assert_equal 100.0, quote.vat_amount
    assert_equal 600.0, quote.total_amount
    assert_equal "sent", quote.status
  end

  test "creates quote with multiple items" do
    items = [
      { description: "Main d'oeuvre", quantity: 8, unit: "heure", unit_price: 45 },
      { description: "Matériaux", quantity: 1, unit: "forfait", unit_price: 200 }
    ]
    
    result = @tool.execute(client_id: @client.id, items: items)
    
    assert result[:success]
    assert_equal 2, result[:data][:items_count]
    
    quote = Quote.find(result[:data][:quote_id])
    assert_equal 560.0, quote.subtotal_amount # 360 + 200
    assert_equal 112.0, quote.vat_amount
    assert_equal 672.0, quote.total_amount
  end

  test "creates quote with custom VAT rate" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items, vat_rate: 10)
    
    assert result[:success]
    assert_equal "10.0%", result[:data][:vat_rate]
    
    quote = Quote.find(result[:data][:quote_id])
    assert_equal 10.0, quote.vat_rate
    assert_equal 10.0, quote.vat_amount
    assert_equal 110.0, quote.total_amount
  end

  test "creates quote with notes" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items, notes: "Devis valable 30 jours")
    
    assert result[:success]
    
    quote = Quote.find(result[:data][:quote_id])
    assert_equal "Devis valable 30 jours", quote.notes
  end

  test "creates quote with custom validity period" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items, validity_days: 60)
    
    assert result[:success]
    
    quote = Quote.find(result[:data][:quote_id])
    assert_equal Date.current + 60.days, quote.validity_date
  end

  test "returns error when user has pending subscription" do
    pending_user = users(:pending_user)
    pending_user.clients.create!(name: "Client", address: "Addr")
    
    tool = LlmTools::CreateQuote.new(user: pending_user)
    items = [{ description: "Test", unit_price: 100 }]
    
    result = tool.execute(client_id: pending_user.clients.first.id, items: items)
    
    refute result[:success]
    assert_match(/abonnement actif/, result[:error])
  end

  test "returns error when client not found" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: 99999, items: items)
    
    refute result[:success]
    assert_match(/Client.*non trouvé/, result[:error])
  end

  test "returns error when items are empty" do
    result = @tool.execute(client_id: @client.id, items: [])
    
    refute result[:success]
    assert_match(/ligne.*obligatoire/, result[:error])
  end

  test "returns error when items are nil" do
    result = @tool.execute(client_id: @client.id, items: nil)
    
    refute result[:success]
    assert_match(/ligne.*obligatoire/, result[:error])
  end

  test "returns error when item description is missing" do
    items = [{ unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items)
    
    refute result[:success]
    assert_match(/Description manquante/, result[:error])
  end

  test "returns error when item unit_price is missing" do
    items = [{ description: "Test" }]
    
    result = @tool.execute(client_id: @client.id, items: items)
    
    refute result[:success]
    assert_match(/Prix unitaire invalide/, result[:error])
  end

  test "returns error for invalid VAT rate" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items, vat_rate: 150)
    
    refute result[:success]
    assert_match(/TVA/, result[:error])
  end

  test "default quantity is 1" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items)
    
    assert result[:success]
    
    quote = Quote.find(result[:data][:quote_id])
    assert_equal 1.0, quote.items.first.quantity
  end

  test "default unit is unité" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items)
    
    assert result[:success]
    
    quote = Quote.find(result[:data][:quote_id])
    assert_equal "unité", quote.items.first.unit
  end

  test "logs execution on success" do
    items = [{ description: "Test", unit_price: 100 }]
    
    assert_difference "SystemLog.count", 1 do
      @tool.execute(client_id: @client.id, items: items)
    end
    
    log = SystemLog.last
    assert_equal "tool_quote_created", log.event
  end

  test "sends summary via WhatsApp" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items)
    
    assert result[:success]
    assert result[:data][:pdf_sent]
    assert_requested :post, %r{api.unipile.com.*/messages}
  end
end
