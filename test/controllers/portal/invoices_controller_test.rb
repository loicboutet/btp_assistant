# frozen_string_literal: true

require "test_helper"

class ClientInvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:active_user)
    @invoice = invoices(:invoice_one)
    @other_user = users(:turkish_user)
    @other_invoice = invoices(:invoice_turkish)
  end

  # ===== Authentication Tests =====

  test "index redirects when not authenticated" do
    get client_invoices_path
    assert_redirected_to root_path
  end

  test "show redirects when not authenticated" do
    get client_invoice_path(@invoice)
    assert_redirected_to root_path
  end

  # ===== Index Tests =====

  test "index shows user invoices" do
    login_via_signed_url(@user)
    
    get client_invoices_path
    assert_response :success
    assert_select "h3", text: @invoice.invoice_number
  end

  test "index does not show other user invoices" do
    login_via_signed_url(@user)
    
    get client_invoices_path
    assert_response :success
    assert_select "h3", text: @other_invoice.invoice_number, count: 0
  end

  test "index filters by status" do
    login_via_signed_url(@user)
    
    get client_invoices_path(status: "sent")
    assert_response :success
    assert_select "h3", text: @invoice.invoice_number
  end

  test "index filters by client_id" do
    login_via_signed_url(@user)
    
    get client_invoices_path(client_id: @invoice.client_id)
    assert_response :success
    assert_select "h3", text: @invoice.invoice_number
  end

  test "index search works" do
    login_via_signed_url(@user)
    
    get client_invoices_path(search: "FACT-2025-0001")
    assert_response :success
    assert_select "h3", text: @invoice.invoice_number
  end

  test "index shows empty state when no invoices" do
    new_user = User.create!(
      phone_number: "+33699887766",
      subscription_status: "active"
    )
    
    login_via_signed_url(new_user)
    
    get client_invoices_path
    assert_response :success
    assert_match(/Aucune facture/, response.body)
  end

  # ===== Show Tests =====

  test "show displays invoice details" do
    login_via_signed_url(@user)
    
    get client_invoice_path(@invoice)
    assert_response :success
    assert_select "h2", text: @invoice.invoice_number
    assert_select "p", text: @invoice.client.name
  end

  test "show returns 404 for other user invoice" do
    login_via_signed_url(@user)
    
    get client_invoice_path(@other_invoice)
    assert_redirected_to client_invoices_path
    follow_redirect!
    assert_match(/non trouvé/, flash[:alert])
  end

  test "show displays paid status when invoice is paid" do
    @paid_invoice = invoices(:invoice_paid)
    login_via_signed_url(@user)
    
    get client_invoice_path(@paid_invoice)
    assert_response :success
    assert_select ".text-green-600", /Payée/
  end

  test "show displays link to related quote" do
    login_via_signed_url(@user)
    
    get client_invoice_path(@invoice)
    assert_response :success
    assert_select "a[href=?]", client_quote_path(@invoice.quote)
  end

  # ===== PDF Tests =====

  test "pdf downloads invoice as PDF" do
    login_via_signed_url(@user)
    
    get pdf_client_invoice_path(@invoice)
    assert_response :success
    assert_equal "application/pdf", response.content_type
    assert_match(/attachment/, response.headers["Content-Disposition"])
    assert_match(/#{@invoice.invoice_number}\.pdf/, response.headers["Content-Disposition"])
  end

  test "pdf returns 404 for other user invoice" do
    login_via_signed_url(@user)
    
    get pdf_client_invoice_path(@other_invoice)
    assert_redirected_to client_invoices_path
  end

  private

  def login_via_signed_url(user)
    token = SignedUrlService.generate_token(user)
    get signed_user_access_path(token: token)
    follow_redirect! if response.redirect?
  end
end
