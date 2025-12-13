# frozen_string_literal: true

require "test_helper"

class UserSessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Use unique phone number to avoid fixture conflicts
    @user = User.create!(
      phone_number: "+33688997766",
      company_name: "Test BTP Sessions"
    )
  end

  test "should redirect to dashboard with valid token" do
    token = SignedUrlService.generate_token(@user)
    
    get signed_user_access_path(token: token)
    
    assert_redirected_to client_dashboard_path
    assert_equal @user.id, session[:user_id]
  end

  test "should show expired page for expired token" do
    token = SignedUrlService.generate_token(@user)
    
    travel 31.minutes do
      get signed_user_access_path(token: token)
      
      assert_response :success
      assert_select "h1", "Lien expiré"
    end
  end

  test "should show invalid page for invalid token" do
    get signed_user_access_path(token: "invalid_token_here")
    
    assert_response :success
    assert_select "h1", "Lien invalide"
  end

  test "should update user last_activity_at on valid token" do
    token = SignedUrlService.generate_token(@user)
    
    assert_nil @user.last_activity_at
    
    get signed_user_access_path(token: token)
    
    @user.reload
    assert_not_nil @user.last_activity_at
  end

  test "should create system log on valid access" do
    token = SignedUrlService.generate_token(@user)
    
    assert_difference 'SystemLog.count', 1 do
      get signed_user_access_path(token: token)
    end
    
    log = SystemLog.last
    assert_equal 'user_web_access', log.event
    assert_equal @user.id, log.user_id
  end

  test "should create system log on expired access" do
    token = SignedUrlService.generate_token(@user)
    
    travel 31.minutes do
      assert_difference 'SystemLog.count', 1 do
        get signed_user_access_path(token: token)
      end
      
      log = SystemLog.last
      assert_equal 'user_expired_link', log.event
    end
  end

  test "should create system log on invalid access" do
    assert_difference 'SystemLog.count', 1 do
      get signed_user_access_path(token: "invalid")
    end
    
    log = SystemLog.last
    assert_equal 'user_invalid_link', log.event
    assert_equal 'warning', log.log_type
  end
end
