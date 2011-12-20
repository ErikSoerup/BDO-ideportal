require File.dirname(__FILE__) + '/../test_helper'
require 'twitter_test_helper'
require 'facebook_test_helper'
require 'sessions_controller'

class SessionsControllerTest < ActionController::TestCase
  scenario :basic
  
  include TwitterTestHelper
  include FacebookTestHelper

  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_login_and_redirect
    post :create, :email => 'quentin@example.com', :password => 'test'
    assert_equal @quentin.id, session[:user_id]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, :email => 'quentin@example.com', :password => 'bad password'
    assert_nil session[:user_id]
    assert_response :success
  end

  def test_can_log_in_if_not_activated
    post :create, :email => 'aaron@example.com', :password => 'test'
    assert session[:user_id]
    assert_response :success
    assert_template 'inactive'
  end

  def test_should_logout
    login_as @quentin
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end

  def test_should_remember_me
    post :create, :email => 'quentin@example.com', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :create, :email => 'quentin@example.com', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as @quentin
    get :destroy
    assert_nil @response.cookies["auth_token"]
  end

  def test_should_login_with_cookie
    users(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end
  
  def test_initiate_twitter_login
    expect_twitter_auth_request
    get :new_twitter
    assert_twitter_redirect_with_callback create_twitter_session_url
  end
  
  def test_complete_twitter_login
    expect_twitter_auth_verificiation 'twit'
    
    twitter_callback :create_twitter
    
    assert_equal @tweeter.id, session[:user_id]
    @tweeter.reload
    assert_equal 'tw_token',  @tweeter.twitter_token
    assert_equal 'tw_secret', @tweeter.twitter_secret
  end

  def test_deny_twitter_login
    expect_no_twitter_auth_verification

    twitter_callback_denied :create_twitter

    assert_nil session[:user_id]
    assert_redirected_to login_path
  end
  
  def test_unknown_twitter_login_prompts_new_account
    expect_twitter_auth_verificiation 'dongle'
    
    twitter_callback :create_twitter

    assert_nil session[:user_id]
    assert_redirected_to new_user_path(
      :user => {
        :twitter_handle => 'dongle',
        :twitter_token => 'tw_token',
        :twitter_secret => 'tw_secret',
        :name => 'Bill' })
  end

  def test_complete_facebook_login
    mock_facebook_user '4207849480'
    
    get :create_facebook
    
    assert_equal @facebooker.id, session[:user_id]
    @facebooker.reload
    assert_equal 'mock_fb_access_token', @facebooker.facebook_access_token
  end
  
  def test_unknown_facebook_login_prompts_new_account
    mock_facebook_user '12345678'
    
    get :create_facebook
    
    assert_nil session[:user_id]
    assert_redirected_to new_user_path(
      :user => {
        :name => 'Bill',
        :email => 'dongle@frux.com',
        :facebook_name => 'Bill' },
      :facebook_create => true)
  end
  
  def test_deny_facebook_login
    # This is an obscure path. The javascript normally won't call create_facebook unless there's an authorized
    # session, so this happens only in the case when the session is somehow invalid or the javascript misfires.
    mock_facebook_user nil
    
    get :create_facebook
    
    assert_nil session[:user_id]
    assert_redirected_to login_path
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
