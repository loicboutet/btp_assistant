# frozen_string_literal: true

require "test_helper"

class LlmTools::CreateClientTest < ActiveSupport::TestCase
  setup do
    @user = users(:active_user)
    @tool = LlmTools::CreateClient.new(user: @user)
  end

  test "creates client with only name" do
    result = @tool.execute(name: "Nouveau Client")
    
    assert result[:success]
    assert_equal "Nouveau Client", result[:data][:name]
    assert result[:data][:client_id].present?
    
    client = Client.find(result[:data][:client_id])
    assert_equal "Nouveau Client", client.name
    assert_equal "whatsapp", client.created_via
  end

  test "creates client with all fields" do
    result = @tool.execute(
      name: "Entreprise ABC",
      address: "123 Rue de Test, 75001 Paris",
      siret: "12345678901234",
      contact_phone: "+33612345678",
      contact_email: "contact@abc.fr"
    )
    
    assert result[:success]
    
    client = Client.find(result[:data][:client_id])
    assert_equal "Entreprise ABC", client.name
    assert_equal "123 Rue de Test, 75001 Paris", client.address
    assert_equal "12345678901234", client.siret
    assert_equal "+33612345678", client.contact_phone
    assert_equal "contact@abc.fr", client.contact_email
  end

  test "returns error when name is blank" do
    result = @tool.execute(name: "")
    
    refute result[:success]
    assert_match(/nom du client est obligatoire/, result[:error])
    assert_equal "name", result[:field]
  end

  test "returns error when name is nil" do
    result = @tool.execute(name: nil)
    
    refute result[:success]
    assert_match(/nom du client est obligatoire/, result[:error])
  end

  test "returns error for invalid SIRET" do
    result = @tool.execute(name: "Test", siret: "123")
    
    refute result[:success]
    assert_match(/SIRET/, result[:error])
    assert_equal "siret", result[:field]
  end

  test "returns error for invalid email" do
    result = @tool.execute(name: "Test", contact_email: "not-an-email")
    
    refute result[:success]
    assert_match(/email invalide/, result[:error])
    assert_equal "email", result[:field]
  end

  test "returns error for duplicate client name" do
    @user.clients.create!(name: "Existing Client")
    
    result = @tool.execute(name: "Existing Client")
    
    refute result[:success]
    assert_match(/existe déjà/, result[:error])
  end

  test "duplicate check is case insensitive" do
    @user.clients.create!(name: "Existing Client")
    
    result = @tool.execute(name: "EXISTING CLIENT")
    
    refute result[:success]
    assert_match(/existe déjà/, result[:error])
  end

  test "strips whitespace from fields" do
    result = @tool.execute(
      name: "  Test Client  ",
      address: "  123 Rue  ",
      contact_email: "  TEST@EXAMPLE.COM  "
    )
    
    assert result[:success]
    
    client = Client.find(result[:data][:client_id])
    assert_equal "Test Client", client.name
    assert_equal "123 Rue", client.address
    assert_equal "test@example.com", client.contact_email
  end

  test "strips whitespace from SIRET" do
    result = @tool.execute(
      name: "Test Client",
      siret: "123 456 789 01234"
    )
    
    assert result[:success]
    
    client = Client.find(result[:data][:client_id])
    assert_equal "12345678901234", client.siret
  end

  test "logs execution on success" do
    assert_difference "SystemLog.count", 1 do
      @tool.execute(name: "Logged Client")
    end
    
    log = SystemLog.last
    assert_equal "tool_client_created", log.event
  end

  test "returns formatted SIRET in response" do
    result = @tool.execute(
      name: "Test Client",
      siret: "12345678901234"
    )
    
    assert result[:success]
    assert_equal "123 456 789 01234", result[:data][:siret]
  end
end
