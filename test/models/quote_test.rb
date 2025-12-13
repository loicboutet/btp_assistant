# frozen_string_literal: true

require "test_helper"

class QuoteTest < ActiveSupport::TestCase
  def setup
    # Use a unique phone number to avoid fixture conflicts
    @user = User.create!(
      phone_number: "+33655443322",
      company_name: "Test BTP Quote"
    )
    @client = Client.create!(
      user: @user,
      name: "Client Test"
    )
    @quote = Quote.new(
      user: @user,
      client: @client,
      issue_date: Date.current,
      validity_date: 30.days.from_now.to_date
    )
  end

  # Sequential numbering tests
  test "should auto-assign quote number on create" do
    @quote.save!
    assert_match(/\ADEVIS-\d{4}-0001\z/, @quote.quote_number)
  end

  test "should increment quote number sequentially" do
    @quote.save!
    
    quote2 = Quote.create!(
      user: @user,
      client: @client,
      issue_date: Date.current
    )
    
    assert_equal "DEVIS-#{Date.current.year}-0001", @quote.quote_number
    assert_equal "DEVIS-#{Date.current.year}-0002", quote2.quote_number
  end

  test "should scope quote numbering per user" do
    @quote.save!
    
    user2 = User.create!(phone_number: "+33644332211")
    client2 = Client.create!(user: user2, name: "Other Client")
    
    quote2 = Quote.create!(
      user: user2,
      client: client2,
      issue_date: Date.current
    )
    
    # Both users should start at 0001
    assert_equal "DEVIS-#{Date.current.year}-0001", @quote.quote_number
    assert_equal "DEVIS-#{Date.current.year}-0001", quote2.quote_number
  end

  # Amount calculation tests
  test "should calculate totals from items" do
    @quote.save!
    
    @quote.items.create!(description: "Travaux maçonnerie", quantity: 10, unit_price: 100)
    @quote.items.create!(description: "Matériaux", quantity: 5, unit_price: 50)
    
    @quote.reload
    @quote.send(:calculate_totals)
    @quote.save!
    
    assert_equal 1250.0, @quote.subtotal_amount  # 10*100 + 5*50
    assert_equal 250.0, @quote.vat_amount        # 1250 * 20%
    assert_equal 1500.0, @quote.total_amount     # 1250 + 250
  end

  test "should handle custom VAT rate" do
    @quote.vat_rate = 10.0
    @quote.save!
    
    @quote.items.create!(description: "Service", quantity: 1, unit_price: 1000)
    @quote.reload
    @quote.send(:calculate_totals)
    @quote.save!
    
    assert_equal 1000.0, @quote.subtotal_amount
    assert_equal 100.0, @quote.vat_amount        # 1000 * 10%
    assert_equal 1100.0, @quote.total_amount
  end

  # Status tests
  test "should be draft by default" do
    @quote.save!
    assert @quote.draft?
    assert @quote.can_be_edited?
  end

  test "should mark as sent" do
    @quote.save!
    @quote.mark_as_sent!
    
    assert @quote.sent?
    assert_not_nil @quote.sent_via_whatsapp_at
  end

  test "should allow invoice creation only when accepted" do
    @quote.save!
    assert_not @quote.can_create_invoice?
    
    @quote.mark_as_accepted!
    assert @quote.can_create_invoice?
  end

  # Validation tests
  test "should not be valid without user" do
    quote = Quote.new(client: @client, issue_date: Date.current)
    assert_not quote.valid?
    assert_includes quote.errors[:user], "must exist"
  end

  test "should not be valid without client" do
    @quote.client = nil
    assert_not @quote.valid?
    assert_includes @quote.errors[:client], "must exist"
  end

  test "should not be valid without issue_date" do
    @quote.issue_date = nil
    assert_not @quote.valid?
  end

  # Expiry tests
  test "should identify expired quotes" do
    @quote.validity_date = 1.day.ago.to_date
    @quote.save!
    
    assert @quote.expired?
  end

  test "should not be expired with future validity date" do
    @quote.validity_date = 30.days.from_now.to_date
    @quote.save!
    
    assert_not @quote.expired?
  end
end
