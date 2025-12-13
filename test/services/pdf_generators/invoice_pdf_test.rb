# frozen_string_literal: true

require "test_helper"

class PdfGenerators::InvoicePdfTest < ActiveSupport::TestCase
  setup do
    @user = users(:active_user)
    @client = clients(:client_acme)
    @invoice = invoices(:invoice_one)
  end

  test "generates valid PDF binary" do
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)
    output = pdf.to_pdf

    assert output.is_a?(String)
    assert output.start_with?("%PDF")
    assert output.length > 1000, "PDF should have substantial content"
  end

  test "to_io returns StringIO" do
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)
    io = pdf.to_io

    assert io.is_a?(StringIO)
    content = io.read
    assert content.start_with?("%PDF")
  end

  test "handles missing user company info gracefully" do
    @user.update!(company_name: nil, vat_number: nil, address: nil, siret: nil)
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles missing client info gracefully" do
    @client.update!(address: nil, siret: nil, contact_phone: nil, contact_email: nil)
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles multiple items" do
    # Invoice already has 2 items from fixtures
    assert @invoice.items.count >= 2
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles notes" do
    @invoice.update!(notes: "Conditions de paiement speciales")
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles invoice without notes" do
    @invoice.update!(notes: nil)
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles zero VAT rate" do
    @invoice.update!(vat_rate: 0)
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles different VAT rates" do
    @invoice.update!(vat_rate: 5.5)
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles nil due date" do
    @invoice.update!(due_date: nil)
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles large amounts" do
    @invoice.update!(subtotal_amount: 1_234_567.89, vat_amount: 246_913.58, total_amount: 1_481_481.47)
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles items with decimal quantities" do
    item = @invoice.items.first
    item.update!(quantity: 2.5)
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles invoice linked to quote" do
    # invoice_one is linked to quote_one
    assert @invoice.quote.present?
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles invoice without quote" do
    invoice_no_quote = invoices(:invoice_paid)
    assert_nil invoice_no_quote.quote
    pdf = PdfGenerators::InvoicePdf.new(invoice_no_quote, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles paid invoice" do
    paid_invoice = invoices(:invoice_paid)
    assert paid_invoice.paid?
    pdf = PdfGenerators::InvoicePdf.new(paid_invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "handles user with VAT number" do
    @user.update!(vat_number: "FR12345678901")
    pdf = PdfGenerators::InvoicePdf.new(@invoice, @user)

    assert_nothing_raised { pdf.to_pdf }
  end

  test "generates PDF for Turkish user" do
    turkish_user = users(:turkish_user)
    invoice = invoices(:invoice_turkish)
    pdf = PdfGenerators::InvoicePdf.new(invoice, turkish_user)

    assert_nothing_raised { pdf.to_pdf }
    assert pdf.to_pdf.start_with?("%PDF")
  end
end
