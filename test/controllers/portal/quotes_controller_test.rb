# frozen_string_literal: true

require "test_helper"

class ClientQuotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:active_user)
    @quote = quotes(:quote_one)
    @other_user = users(:turkish_user)
    @other_quote = quotes(:quote_turkish)
  end

  # ===== Authentication Tests =====

  test "index redirects when not authenticated" do
    get client_quotes_path
    assert_redirected_to root_path
  end

  test "show redirects when not authenticated" do
    get client_quote_path(@quote)
    assert_redirected_to root_path
  end

  # ===== Index Tests =====

  test "index shows user quotes" do
    login_via_signed_url(@user)
    
    get client_quotes_path
    assert_response :success
    assert_select "h3", text: @quote.quote_number
  end

  test "index does not show other user quotes" do
    login_via_signed_url(@user)
    
    get client_quotes_path
    assert_response :success
    assert_select "h3", text: @other_quote.quote_number, count: 0
  end

  test "index filters by status" do
    login_via_signed_url(@user)
    
    get client_quotes_path(status: "sent")
    assert_response :success
    assert_select "h3", text: @quote.quote_number
  end

  test "index filters by client_id" do
    login_via_signed_url(@user)
    
    get client_quotes_path(client_id: @quote.client_id)
    assert_response :success
    assert_select "h3", text: @quote.quote_number
  end

  test "index search works" do
    login_via_signed_url(@user)
    
    get client_quotes_path(search: "DEVIS-2025-0001")
    assert_response :success
    assert_select "h3", text: @quote.quote_number
  end

  test "index shows empty state when no quotes" do
    new_user = User.create!(
      phone_number: "+33699887766",
      subscription_status: "active"
    )
    
    login_via_signed_url(new_user)
    
    get client_quotes_path
    assert_response :success
    assert_match(/Aucun devis/, response.body)
  end

  # ===== Show Tests =====

  test "show displays quote details" do
    login_via_signed_url(@user)
    
    get client_quote_path(@quote)
    assert_response :success
    assert_select "h2", text: @quote.quote_number
    assert_select "p", text: @quote.client.name
  end

  test "show returns 404 for other user quote" do
    login_via_signed_url(@user)
    
    get client_quote_path(@other_quote)
    assert_redirected_to client_quotes_path
    follow_redirect!
    assert_match(/non trouvé/, flash[:alert])
  end

  test "show displays quote items" do
    @quote.items.create!(
      description: "Test item",
      quantity: 2,
      unit_price: 100,
      total_price: 200
    )
    
    login_via_signed_url(@user)
    
    get client_quote_path(@quote)
    assert_response :success
    assert_select "td", text: "Test item"
  end

  # ===== PDF Tests =====

  test "pdf downloads quote as PDF" do
    login_via_signed_url(@user)
    
    get pdf_client_quote_path(@quote)
    assert_response :success
    assert_equal "application/pdf", response.content_type
    assert_match(/attachment/, response.headers["Content-Disposition"])
    assert_match(/#{@quote.quote_number}\.pdf/, response.headers["Content-Disposition"])
  end

  test "pdf returns 404 for other user quote" do
    login_via_signed_url(@user)
    
    get pdf_client_quote_path(@other_quote)
    assert_redirected_to client_quotes_path
  end

  # ===== Pagination Tests =====

  test "pagination works correctly" do
    login_via_signed_url(@user)
    
    25.times do |i|
      @user.quotes.create!(
        client: @quote.client,
        issue_date: Date.current,
        status: "draft"
      )
    end
    
    get client_quotes_path
    assert_response :success
    
    get client_quotes_path(page: 2)
    assert_response :success
  end

  private

  def login_via_signed_url(user)
    token = SignedUrlService.generate_token(user)
    get signed_user_access_path(token: token)
    follow_redirect! if response.redirect?
  end
end
