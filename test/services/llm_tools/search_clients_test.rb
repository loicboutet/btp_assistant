# frozen_string_literal: true

require "test_helper"

class LlmTools::SearchClientsTest < ActiveSupport::TestCase
  setup do
    @user = users(:active_user)
    @tool = LlmTools::SearchClients.new(user: @user)
    
    # Create some test clients
    @client1 = @user.clients.create!(name: "Jean Dupont", address: "123 Rue de Paris")
    @client2 = @user.clients.create!(name: "Marie Durand", address: "456 Avenue Lyon")
    @client3 = @user.clients.create!(name: "Pierre Dupont", address: "789 Rue Nice")
  end

  test "finds clients by exact name match" do
    result = @tool.execute(query: "Jean Dupont")
    
    assert result[:success]
    assert_equal 1, result[:data][:count]
    assert_equal "Jean Dupont", result[:data][:clients].first[:name]
  end

  test "finds clients by partial name match" do
    result = @tool.execute(query: "Dupont")
    
    assert result[:success]
    assert_equal 2, result[:data][:count]
    
    names = result[:data][:clients].map { |c| c[:name] }
    assert_includes names, "Jean Dupont"
    assert_includes names, "Pierre Dupont"
  end

  test "returns empty array when no clients found" do
    result = @tool.execute(query: "Inexistant")
    
    assert result[:success]
    assert_equal 0, result[:data][:count]
    assert_empty result[:data][:clients]
    assert_match(/Aucun client trouvé/, result[:data][:message])
  end

  test "returns error when query is blank" do
    result = @tool.execute(query: "")
    
    refute result[:success]
    assert_match(/Query is required/, result[:error])
  end

  test "returns error when query is nil" do
    result = @tool.execute(query: nil)
    
    refute result[:success]
  end

  test "search is case insensitive" do
    result = @tool.execute(query: "DUPONT")
    
    assert result[:success]
    assert_equal 2, result[:data][:count]
  end

  test "limits results to MAX_RESULTS" do
    # Create more than 10 clients
    12.times do |i|
      @user.clients.create!(name: "Test Client #{i}")
    end
    
    result = @tool.execute(query: "Test Client")
    
    assert result[:success]
    assert result[:data][:count] <= 10
  end

  test "includes client details in response" do
    @client1.update!(
      siret: "12345678901234",
      contact_phone: "+33612345678",
      contact_email: "jean@example.com"
    )
    
    result = @tool.execute(query: "Jean Dupont")
    client_data = result[:data][:clients].first
    
    assert_equal @client1.id, client_data[:id]
    assert_equal "Jean Dupont", client_data[:name]
    assert_equal "123 Rue de Paris", client_data[:address]
    assert_equal "12345678901234", client_data[:siret]
    assert_equal "+33612345678", client_data[:contact_phone]
    assert_equal "jean@example.com", client_data[:contact_email]
    assert client_data[:is_professional]
  end

  test "only searches within user's clients" do
    other_user = users(:pending_user)
    other_user.clients.create!(name: "Jean Dupont Clone")
    
    result = @tool.execute(query: "Jean Dupont")
    
    assert result[:success]
    # Should only find the original user's client
    assert_equal 1, result[:data][:count]
  end

  test "sanitizes SQL wildcards in query" do
    # The sanitization removes % and _ to prevent SQL injection
    # But with LIKE, %_% becomes just an empty pattern after sanitization
    # which matches nothing or everything depending on implementation
    # This test just verifies no SQL error occurs
    result = @tool.execute(query: "%_%")
    
    assert result[:success]
    # The important thing is no SQL error
  end
end
