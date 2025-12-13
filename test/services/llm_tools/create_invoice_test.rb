# frozen_string_literal: true

require "test_helper"

class LlmTools::CreateInvoiceTest < ActiveSupport::TestCase
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
    
    @tool = LlmTools::CreateInvoice.new(user: @user)
  end

  test "creates invoice with single item" do
    items = [
      { description: "Travaux de maçonnerie", quantity: 10, unit: "m²", unit_price: 50 }
    ]
    
    result = @tool.execute(client_id: @client.id, items: items)
    
    assert result[:success]
    assert result[:data][:invoice_id].present?
    assert_match(/FACT-\d{4}-\d{4}/, result[:data][:invoice_number])
    assert_equal "Test Client", result[:data][:client_name]
    assert_equal 1, result[:data][:items_count]
    
    invoice = Invoice.find(result[:data][:invoice_id])
    assert_equal 500.0, invoice.subtotal_amount
    assert_equal 100.0, invoice.vat_amount
    assert_equal 600.0, invoice.total_amount
    assert_equal "sent", invoice.status
  end

  test "creates invoice with multiple items" do
    items = [
      { description: "Main d'oeuvre", quantity: 8, unit: "heure", unit_price: 45 },
      { description: "Matériaux", quantity: 1, unit: "forfait", unit_price: 200 }
    ]
    
    result = @tool.execute(client_id: @client.id, items: items)
    
    assert result[:success]
    assert_equal 2, result[:data][:items_count]
    
    invoice = Invoice.find(result[:data][:invoice_id])
    assert_equal 560.0, invoice.subtotal_amount
    assert_equal 672.0, invoice.total_amount
  end

  test "creates invoice with custom VAT rate" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items, vat_rate: 5.5)
    
    assert result[:success]
    assert_equal "5.5%", result[:data][:vat_rate]
    
    invoice = Invoice.find(result[:data][:invoice_id])
    assert_equal 5.5, invoice.vat_rate
    assert_equal 5.5, invoice.vat_amount
    assert_equal 105.5, invoice.total_amount
  end

  test "creates invoice with notes" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items, notes: "Paiement sous 30 jours")
    
    assert result[:success]
    
    invoice = Invoice.find(result[:data][:invoice_id])
    assert_equal "Paiement sous 30 jours", invoice.notes
  end

  test "creates invoice with custom due period" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items, due_days: 45)
    
    assert result[:success]
    
    invoice = Invoice.find(result[:data][:invoice_id])
    assert_equal Date.current + 45.days, invoice.due_date
  end

  test "creates invoice linked to quote" do
    quote = @user.quotes.create!(
      client: @client,
      issue_date: Date.current,
      status: "accepted"
    )
    quote.items.create!(description: "Test", unit_price: 100)
    
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items, quote_id: quote.id)
    
    assert result[:success]
    assert_equal quote.quote_number, result[:data][:from_quote]
    
    invoice = Invoice.find(result[:data][:invoice_id])
    assert_equal quote.id, invoice.quote_id
  end

  test "returns error when quote belongs to different client" do
    other_client = @user.clients.create!(name: "Other Client")
    quote = @user.quotes.create!(client: other_client, issue_date: Date.current)
    
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items, quote_id: quote.id)
    
    refute result[:success]
    assert_match(/autre client/, result[:error])
  end

  test "returns error when quote not found" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items, quote_id: 99999)
    
    refute result[:success]
    assert_match(/Devis.*non trouvé/, result[:error])
  end

  test "returns error when user has canceled subscription" do
    canceled_user = users(:canceled_user)
    canceled_user.clients.create!(name: "Client", address: "Addr")
    
    tool = LlmTools::CreateInvoice.new(user: canceled_user)
    items = [{ description: "Test", unit_price: 100 }]
    
    result = tool.execute(client_id: canceled_user.clients.first.id, items: items)
    
    refute result[:success]
    assert_match(/abonnement.*expiré/, result[:error])
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

  test "returns error when item description is missing" do
    items = [{ unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items)
    
    refute result[:success]
    assert_match(/Description manquante/, result[:error])
  end

  test "returns error for invalid VAT rate" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items, vat_rate: -5)
    
    refute result[:success]
    assert_match(/TVA/, result[:error])
  end

  test "logs execution on success" do
    items = [{ description: "Test", unit_price: 100 }]
    
    assert_difference "SystemLog.count", 1 do
      @tool.execute(client_id: @client.id, items: items)
    end
    
    log = SystemLog.last
    assert_equal "tool_invoice_created", log.event
  end

  test "sends summary via WhatsApp" do
    items = [{ description: "Test", unit_price: 100 }]
    
    result = @tool.execute(client_id: @client.id, items: items)
    
    assert result[:success]
    assert result[:data][:pdf_sent]
    assert_requested :post, %r{api.unipile.com.*/messages}
  end
end
