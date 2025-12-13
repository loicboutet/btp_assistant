# frozen_string_literal: true

require "test_helper"

class LlmTools::ExecutorTest < ActiveSupport::TestCase
  setup do
    @user = users(:active_user)
    @executor = LlmTools::Executor.new(user: @user)
    
    # Setup app settings for Unipile
    AppSetting.instance.update!(
      unipile_dsn: "https://api.unipile.com:13211",
      unipile_api_key: "test-key",
      unipile_account_id: "test-account"
    )
  end

  # ==========================================
  # Tool Existence Tests
  # ==========================================

  test "tool_exists? returns true for valid tools" do
    assert LlmTools::Executor.tool_exists?("search_clients")
    assert LlmTools::Executor.tool_exists?("create_client")
    assert LlmTools::Executor.tool_exists?("create_quote")
    assert LlmTools::Executor.tool_exists?("create_invoice")
    assert LlmTools::Executor.tool_exists?("list_recent_quotes")
    assert LlmTools::Executor.tool_exists?("list_recent_invoices")
    assert LlmTools::Executor.tool_exists?("send_quote_pdf")
    assert LlmTools::Executor.tool_exists?("send_invoice_pdf")
    assert LlmTools::Executor.tool_exists?("mark_invoice_paid")
    assert LlmTools::Executor.tool_exists?("get_user_info")
    assert LlmTools::Executor.tool_exists?("update_user_info")
    assert LlmTools::Executor.tool_exists?("send_web_link")
    assert LlmTools::Executor.tool_exists?("send_payment_link")
  end

  test "tool_exists? returns false for unknown tools" do
    refute LlmTools::Executor.tool_exists?("unknown_tool")
    refute LlmTools::Executor.tool_exists?("delete_everything")
    refute LlmTools::Executor.tool_exists?("")
  end

  test "available_tools returns all tool names" do
    tools = LlmTools::Executor.available_tools
    
    assert_includes tools, "search_clients"
    assert_includes tools, "create_client"
    assert_includes tools, "create_quote"
    assert_equal 13, tools.length
  end

  # ==========================================
  # Execution Tests
  # ==========================================

  test "execute calls the correct tool" do
    result = @executor.execute(
      tool_name: "search_clients",
      arguments: { query: "Test" }
    )
    
    assert result[:success]
    assert_includes result[:data].keys, :count
    assert_includes result[:data].keys, :clients
  end

  test "execute returns error for unknown tool" do
    result = @executor.execute(
      tool_name: "unknown_tool",
      arguments: {}
    )
    
    refute result[:success]
    assert_match(/Unknown tool/, result[:error])
  end

  test "execute handles string arguments" do
    result = @executor.execute(
      tool_name: "search_clients",
      arguments: '{"query": "Test"}'
    )
    
    assert result[:success]
  end

  test "execute handles empty arguments" do
    result = @executor.execute(
      tool_name: "get_user_info",
      arguments: nil
    )
    
    assert result[:success]
  end

  test "execute handles malformed JSON gracefully" do
    result = @executor.execute(
      tool_name: "search_clients",
      arguments: "not json"
    )
    
    # Should handle gracefully (empty args)
    assert result.key?(:success)
  end

  test "execute catches exceptions from tools" do
    # Force an error by passing invalid arguments
    result = @executor.execute(
      tool_name: "create_client",
      arguments: { name: nil }
    )
    
    refute result[:success]
    assert result[:error].present?
  end

  # ==========================================
  # Tool Definition Alignment Tests
  # ==========================================

  test "all defined tools have corresponding executor mappings" do
    defined_names = LlmTools::ToolDefinitions.names
    executor_names = LlmTools::Executor::TOOLS.keys
    
    defined_names.each do |name|
      assert_includes executor_names, name, "Tool '#{name}' defined but not in executor"
    end
  end

  test "all executor tools have definitions" do
    executor_names = LlmTools::Executor::TOOLS.keys
    defined_names = LlmTools::ToolDefinitions.names
    
    executor_names.each do |name|
      assert_includes defined_names, name, "Tool '#{name}' in executor but not defined"
    end
  end
end
