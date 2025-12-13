# frozen_string_literal: true

require "test_helper"

class SignedUrlServiceTest < ActiveSupport::TestCase
  def setup
    # Use a unique phone number to avoid fixture conflicts
    @user = User.create!(
      phone_number: "+33699887766",
      company_name: "Test BTP Signed URL"
    )
  end

  test "should generate a token" do
    token = SignedUrlService.generate_token(@user)
    
    assert_not_nil token
    assert token.is_a?(String)
    assert token.length > 20
  end

  test "should generate a full URL" do
    url = SignedUrlService.generate_url(@user)
    
    assert_not_nil url
    assert url.include?("/u/")
  end

  test "should verify a valid token" do
    token = SignedUrlService.generate_token(@user)
    result = SignedUrlService.verify(token)
    
    assert_equal :valid, result[:status]
    assert_equal @user.id, result[:user].id
  end

  test "should return invalid for blank token" do
    result = SignedUrlService.verify("")
    
    assert_equal :invalid, result[:status]
    assert_nil result[:user]
  end

  test "should return invalid for nil token" do
    result = SignedUrlService.verify(nil)
    
    assert_equal :invalid, result[:status]
    assert_nil result[:user]
  end

  test "should return invalid for tampered token" do
    token = SignedUrlService.generate_token(@user)
    tampered = token[0...-5] + "XXXXX"
    
    result = SignedUrlService.verify(tampered)
    
    assert_equal :invalid, result[:status]
  end

  test "should return invalid for non-existent user" do
    token = SignedUrlService.generate_token(@user)
    @user.destroy
    
    result = SignedUrlService.verify(token)
    
    assert_equal :invalid, result[:status]
  end

  test "should return expired for old token" do
    # Generate token
    token = SignedUrlService.generate_token(@user)
    
    # Travel forward in time past expiration
    travel 31.minutes do
      result = SignedUrlService.verify(token)
      
      assert_equal :expired, result[:status]
      assert_equal @user.id, result[:user].id
    end
  end

  test "should extract user from expired token" do
    token = SignedUrlService.generate_token(@user)
    
    travel 31.minutes do
      user = SignedUrlService.extract_user_from_expired(token)
      
      assert_not_nil user
      assert_equal @user.id, user.id
    end
  end

  test "should not extract user from valid token" do
    token = SignedUrlService.generate_token(@user)
    
    user = SignedUrlService.extract_user_from_expired(token)
    
    assert_nil user
  end

  test "should not extract user from invalid token" do
    user = SignedUrlService.extract_user_from_expired("invalid_token")
    
    assert_nil user
  end

  test "valid? should return true for valid token" do
    token = SignedUrlService.generate_token(@user)
    
    assert SignedUrlService.valid?(token)
  end

  test "valid? should return false for expired token" do
    token = SignedUrlService.generate_token(@user)
    
    travel 31.minutes do
      assert_not SignedUrlService.valid?(token)
    end
  end

  test "user_from_token should return user for valid token" do
    token = SignedUrlService.generate_token(@user)
    
    user = SignedUrlService.user_from_token(token)
    
    assert_equal @user.id, user.id
  end

  test "user_from_token should return nil for invalid token" do
    user = SignedUrlService.user_from_token("invalid")
    
    assert_nil user
  end

  test "different users should get different tokens" do
    user2 = User.create!(phone_number: "+33677889900")
    
    token1 = SignedUrlService.generate_token(@user)
    token2 = SignedUrlService.generate_token(user2)
    
    assert_not_equal token1, token2
  end

  test "same user should get different tokens at different times" do
    token1 = SignedUrlService.generate_token(@user)
    
    travel 1.second do
      token2 = SignedUrlService.generate_token(@user)
      assert_not_equal token1, token2
    end
  end
end
