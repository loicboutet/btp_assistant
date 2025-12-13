# frozen_string_literal: true

require "test_helper"

class AdminPromptsTest < AdminRequestTestCase
  test "GET /admin/prompts lists prompts" do
    sign_in_admin

    get admin_prompts_path
    assert_response :success

    assert_select "h1", /Prompts LLM/i
    assert_match "system_prompt", response.body
  end

  test "GET /admin/prompts/:id/edit renders" do
    sign_in_admin

    prompt = llm_prompts(:system_prompt)
    get edit_admin_prompt_path(prompt)

    assert_response :success
    assert_select "h1", /Éditer/i
    assert_match prompt.name, response.body
  end

  test "PATCH /admin/prompts/:id updates prompt" do
    sign_in_admin

    prompt = llm_prompts(:system_prompt)
    old_version = prompt.version

    patch admin_prompt_path(prompt), params: {
      llm_prompt: {
        description: "Nouvelle description",
        prompt_text: "Nouveau prompt",
        is_active: true
      }
    }

    assert_redirected_to admin_prompts_path

    prompt.reload
    assert_equal "Nouvelle description", prompt.description
    assert_equal "Nouveau prompt", prompt.prompt_text
    assert prompt.is_active?
    assert_equal old_version + 1, prompt.version
  end

  test "PATCH /admin/prompts/:id with invalid params renders 422" do
    sign_in_admin

    prompt = llm_prompts(:system_prompt)

    patch admin_prompt_path(prompt), params: {
      llm_prompt: {
        prompt_text: "" # invalid
      }
    }

    assert_response :unprocessable_entity
  end

  test "POST /admin/prompts/:id/test returns json (OpenaiClient stubbed)" do
    sign_in_admin

    prompt = llm_prompts(:system_prompt)

    fake_client = stub(chat: { content: "Réponse OK" })
    OpenaiClient.stubs(:new).returns(fake_client)

    post test_admin_prompt_path(prompt), params: { input: "ping", temperature: 0.1 }, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal true, body["success"]
    assert_equal "Réponse OK", body["output"]
  end
end
