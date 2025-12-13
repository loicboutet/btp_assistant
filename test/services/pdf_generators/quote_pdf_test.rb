# frozen_string_literal: true

require "test_helper"

class PdfGenerators::QuotePdfTest < ActiveSupport::TestCase
  setup do
    @user = users(:active_user)
    @client = clients(:client_acme)
    @quote = quotes(:quote_one)
  end

  test "generates valid PDF binary" do
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)
    output = pdf.to_pdf

    assert output.is_a?(String)
    assert output.start_with?("%PDF")
    assert output.length > 1000, "PDF should have substantial content"
  end

  test "to_io returns StringIO" do
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)
    io = pdf.to_io

    assert io.is_a?(StringIO)
    content = io.read
    assert content.start_with?("%PDF")
  end

  test "handles missing user company info gracefully" do
    @user.update!(company_name: nil, vat_number: nil, address: nil, siret: nil)
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles missing client info gracefully" do
    @client.update!(address: nil, siret: nil, contact_phone: nil, contact_email: nil)
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles multiple items" do
    # Quote already has 2 items from fixtures
    assert @quote.items.count >= 2
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles notes" do
    @quote.update!(notes: "Conditions particulieres de paiement")
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles quote without notes" do
    @quote.update!(notes: nil)
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles zero VAT rate" do
    @quote.update!(vat_rate: 0)
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles different VAT rates" do
    @quote.update!(vat_rate: 10)
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles nil validity date" do
    @quote.update!(validity_date: nil)
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles large amounts" do
    @quote.update!(subtotal_amount: 1_234_567.89, vat_amount: 246_913.58, total_amount: 1_481_481.47)
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles items with decimal quantities" do
    item = @quote.items.first
    item.update!(quantity: 2.5)
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles professional client with SIRET" do
    @client.update!(siret: "12345678901234")
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles user with VAT number" do
    @user.update!(vat_number: "FR12345678901")
    pdf = PdfGenerators::QuotePdf.new(@quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "generates PDF for Turkish user" do
    turkish_user = users(:turkish_user)
    quote = quotes(:quote_turkish)
    pdf = PdfGenerators::QuotePdf.new(quote, turkish_user)

    assert_nothing_raised { pdf.to_pdf }
    assert pdf.to_pdf.start_with?("%PDF")
  end
end
