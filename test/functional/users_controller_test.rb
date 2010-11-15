require File.dirname(__FILE__) + '/../test_helper'
require 'twitter_test_helper'
require 'facebook_test_helper'
require 'users_controller'

class UsersControllerTest < ActionController::TestCase
  scenario :basic
  
  include TwitterTestHelper
  include FacebookTestHelper

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @deliveries = ActionMailer::Base.deliveries = []
  end
  
  def test_new_form
    get :new
    assert_response :success
    assert_template 'new'
  end
  
  def test_new_form_for_twitter
    get :new, :user => {
      :twitter_token => '123456', :twitter_secret => 'abcdef', :twitter_handle => 'joe', :name => 'Joe' }
    
    assert_response :success
    assert_template 'new_via_third_party'
    user = assigns(:user)
    assert user
    assert_equal '123456', user.twitter_token
    assert_equal 'abcdef', user.twitter_secret
    assert_equal 'joe', user.twitter_handle
    assert_equal 'Joe', user.name
    assert user.tweet_ideas?
  end
  
  def test_new_form_for_facebook
    mock_facebook_user '12345678'
    
    get :new, :facebook_create => true, :user => {
      :name => 'Joe', :email => 'joe@example.com', :facebook_name => 'Joe FB' }
    
    assert_response :success
    assert_template 'new_via_third_party'
    user = assigns(:user)
    assert user
    assert_equal '12345678', user.facebook_uid
    assert_equal 'mock_fb_access_token', user.facebook_access_token
    assert_equal 'Joe FB', user.facebook_name
    assert_equal 'Joe', user.name
    assert_equal 'joe@example.com', user.email
    assert user.facebook_post_ideas?
  end
  
  def test_should_allow_signup
    assert_difference 'User.count' do
      create_user
      assert_response :redirect
      assert flash[:info]
      assert logged_in?  # Logged in even though not active, because user can still create an idea
      assert_equal 1, @deliveries.size
      assert_email_sent current_user, /#{activate_path(current_user.activation_code)}/
    end
  end
  
  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
      assert_template 'new'
      assert !logged_in?
      assert_equal 0, @deliveries.size
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
      assert !logged_in?
      assert_equal 0, @deliveries.size
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
      assert !logged_in?
      assert_equal 0, @deliveries.size
    end
  end
  
  def test_should_sign_up_user_in_pending_state
    create_user
    assigns(:user).reload
    assert assigns(:user).pending?
  end

  def test_should_sign_up_user_with_activation_code
    create_user
    assigns(:user).reload
    assert_not_nil assigns(:user).activation_code
  end

  def test_sign_up_with_twitter
    assert_difference 'User.count' do
      create_user(
        :twitter_token => '123456', :twitter_secret => 'abcdef', :twitter_handle => 'joe',
        :email => 'frutso@frutso.com', :password => nil, :password_confirmation => nil)
      
      assert_response :redirect
      assert flash[:info]
      assert logged_in?
      
      user = current_user
      assert_equal '123456', user.twitter_token
      assert_equal 'abcdef', user.twitter_secret
      assert_equal 'joe', user.twitter_handle
      assert_nil user.password
      assert user.linked_to_twitter?
      assert !user.tweet_ideas?
      
      assert_account_activated_immediately
    end
  end
  
  def test_sign_up_with_twitter_errors
    assert_no_difference 'User.count' do
      create_user(
        :twitter_token => '123456', :twitter_secret => 'abcdef', :twitter_handle => 'joe',
        :password => nil, :password_confirmation => nil, :terms_of_service => nil)
      assert assigns(:user).errors.on(:terms_of_service)
      assert_response :success
      assert_template 'new_via_third_party'
      assert !logged_in?
      assert_equal 0, @deliveries.size
    end
  end

  def test_sign_up_with_facebook
    assert_difference 'User.count' do
      mock_facebook_user '87654321'
      
      create_user(
        :email => 'frutso@frutso.com', :password => nil, :password_confirmation => nil, :facebook_name => 'Joe FB')
      
      assert_response :redirect
      assert flash[:info]
      assert logged_in?
      
      user = current_user
      assert_equal '87654321', user.facebook_uid
      assert_equal 'mock_fb_access_token', user.facebook_access_token
      assert_equal 'Joe FB', user.facebook_name
      assert_nil user.password
      assert user.linked_to_facebook?
      assert !user.facebook_post_ideas?
      
      assert_account_activated_immediately
    end
  end
  
  def test_sign_up_with_facebook_errors
    assert_no_difference 'User.count' do
      mock_facebook_user '87654321'
      
      create_user(
        :email => 'frutso@frutso.com', :password => nil, :password_confirmation => nil, :facebook_name => 'Joe FB',
        :terms_of_service => nil)
      assert assigns(:user).errors.on(:terms_of_service)
      assert_response :success
      assert_template 'new_via_third_party'
      assert !logged_in?
      assert_equal 0, @deliveries.size
    end
  end

  def test_should_send_activation
    post :send_activation, :email => 'aaron@example.com'
    assert_response :redirect
    assert flash[:info] =~ /aaron@example.com/
    assert !logged_in?
    assert_equal 1, @deliveries.size
    assert_email_sent @aaron, /#{activate_path(@aaron.activation_code)}/
  end
  
  def test_should_activate_user
    assert_nil User.authenticate('aaron', 'test')
    assert !@aaron.active?
    
    get :activate, :activation_code => users(:aaron).activation_code
    
    assert_redirected_to '/'
    assert flash[:info] =~ /activat/i
    assert_equal @aaron, current_user
    @aaron.reload
    assert @aaron.active?
  end
  
  def test_should_not_activate_user_with_wrong_key
    get :activate, :activation_code => 'frutso'
    assert_nil flash[:notice]
    assert_template 'bad_activation_code'
    @aaron.reload
    assert !@aaron.active?
  end

  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_nil flash[:notice]
    assert_template 'bad_activation_code'
    @aaron.reload
    assert !@aaron.active?
  end
  
  def test_should_render_password_reset_form
    get :forgot_password
    assert_response :success
    assert_template 'forgot_password'
  end
  
  def test_should_send_password_reset_email
    post :send_password_reset, :email => 'quentin@example.com'
    assert_response :success
    assert_template 'password_reset_sent'
    assert !logged_in?
    assert_equal 1, @deliveries.size
    assert_email_sent @quentin, /#{password_reset_path(@quentin.activation_code)}/
  end
  
  def test_should_not_send_password_reset_with_bad_email
    post :send_password_reset, :email => 'frutso@example.com'
    assert_response :success
    assert_template 'forgot_password'
    assert assigns(:not_found)
    assert_tag :content => /not in our database/
    assert_equal 0, @deliveries.size
  end
  
  def test_should_send_password_reset_email_for_user_without_password
    post :send_password_reset, :email => 'exhibitionist@example.com'
    assert_response :success
    assert_template 'password_reset_sent'
    assert !logged_in?
    assert_equal 1, @deliveries.size
    assert_email_sent @facebooker, /#{password_reset_path(@facebooker.activation_code)}/
  end
  
  def test_should_allow_new_password
    get :new_password, :activation_code => users(:aaron).activation_code
    
    assert_redirected_to edit_user_path
    assert flash[:info] =~ /password/i
    assert_equal @aaron, current_user
    @aaron.reload
    assert @aaron.active?
  end
  
  def test_should_edit
    login_as @quentin
    get :edit
    assert_response :success
    assert_template 'edit'
    assert_tag :tag => 'input', :attributes => {:value => @quentin.name}
    assert_no_tag :attributes => {:value => 'test'} # password should not be visible
  end
  
  def test_edit_requires_login
    get :edit
    assert_response :redirect
  end
  
  def test_should_update
    login_as @quentin
    post :update, :user => { :name => 'New Quentin', :password => 'newpass', :password_confirmation => 'newpass' }
    assert_response :success
    assert flash[:info]
    assert User.authenticate('quentin@example.com', 'newpass')
    @quentin.reload
    assert_equal 'New Quentin', @quentin.name
    assert_nil User.authenticate('quentin@example.com', 'test')
  end

  def test_update_requires_login
    post :update, :user => { :password => 'newpass', :password_confirmation => 'newpass' }
    assert_response :redirect
    assert User.authenticate('quentin@example.com', 'test') # old pass still in effect
  end

  def test_should_ignore_attempt_to_update_other_user
    login_as @quentin
    post :update, :user_id => @aaron.id, :user => { :id => @aaron.id, :password => 'newpass', :password_confirmation => 'newpass' }
    assert User.find_by_login('quentin@example.com', 'newpass')
    assert User.find_by_login('aaron@example.com', 'test') # unmodified
  end
  
  def test_link_twitter_account_should_send_auth_request
    expect_twitter_auth_request
    
    assert_login_required @quentin do
      post :update, :user => { :zip_code => '12345' }, :link_twitter => 'Button name'
    end
    
    assert_twitter_redirect_with_callback authorize_twitter_url
    @quentin.reload
    assert_equal '12345', @quentin.zip_code
  end
  
  def test_link_twitter_account_bypassed_if_form_errors
    login_as @quentin
    post :update, :user => { :password => 'mis', :password_confirmation => 'match' }, :link_twitter => 'Button name'
    assert_response :success # no redirect
  end
  
  def test_authorize_twitter
    expect_twitter_auth_verificiation 'quentweet'

    assert_login_required @quentin do
      twitter_callback :authorize_twitter
    end
    
    assert_redirected_to edit_user_path
    @quentin.reload
    assert @quentin.linked_to_twitter?
    assert_equal 'quentweet', @quentin.twitter_handle
    assert_equal 'tw_token',  @quentin.twitter_token
    assert_equal 'tw_secret', @quentin.twitter_secret
    assert @quentin.tweet_ideas
  end
  
  def test_authorize_twitter_denied
    expect_no_twitter_auth_verification
    
    assert_login_required @quentin do
      twitter_callback_denied :authorize_twitter
    end
    
    assert_redirected_to edit_user_path
    @quentin.reload
    assert !@quentin.linked_to_twitter?
    assert_nil @quentin.twitter_handle
    assert_nil @quentin.twitter_token
    assert_nil @quentin.twitter_secret
  end

  def test_authorize_twitter_denied_preserves_previous_auth
    expect_no_twitter_auth_verification
    twitter_handle = @tweeter.twitter_handle
    twitter_token  = @tweeter.twitter_token
    twitter_secret = @tweeter.twitter_secret
    
    assert_login_required @tweeter do
      twitter_callback_denied :authorize_twitter
    end
    
    assert_redirected_to edit_user_path
    @tweeter.reload
    assert @tweeter.linked_to_twitter?
    assert_equal twitter_handle, @tweeter.twitter_handle
    assert_equal twitter_token,  @tweeter.twitter_token
    assert_equal twitter_secret, @tweeter.twitter_secret
  end
  
  def test_unlink_twitter_account
    # unlink requires pass
    @tweeter.password = @tweeter.password_confirmation = 'pass'
    @tweeter.save!
    
    assert_login_required @tweeter do
      post :update, :user => { :zip_code => '12345' }, :unlink_twitter => 'Button name'
    end
    
    @tweeter.reload
    assert_equal '12345', @tweeter.zip_code
    assert !@tweeter.linked_to_twitter?
    assert !@tweeter.tweet_ideas
  end
  
  def test_unlink_twitter_account_bypassed_if_form_errors
    # unlink requires pass
    @tweeter.password = @tweeter.password_confirmation = 'pass'
    @tweeter.save!
    
    login_as @tweeter
    post :update, :user => { :password => 'mis', :password_confirmation => 'match' }, :unlink_twitter => 'Button name'
    
    @tweeter.reload
    assert @tweeter.linked_to_twitter?
    assert @tweeter.tweet_ideas
  end
  
  def test_authorize_facebook
    mock_facebook_user '13572468'
    
    assert_login_required @quentin do
      # Whereas as Twitter auth happens entirely server-side, resulting in a callback,
      # Facebook auth happens in part via client-side JS which sets a cookie and the link_facebook flag.
      get :update, :link_facebook => '1'
    end
    
    assert_response :success
    assert_template 'edit'
    @quentin.reload
    assert @quentin.linked_to_facebook?
    assert_equal '13572468', @quentin.facebook_uid
    assert_equal 'mock_fb_access_token',    @quentin.facebook_access_token
    assert @quentin.facebook_post_ideas
  end
  
  def test_authorize_facebook_denied
    mock_facebook_user nil
    
    assert_login_required @quentin do
      # Whereas as Twitter auth happens entirely server-side, resulting in a callback,
      # Facebook auth happens in part via client-side JS which sets a cookie and the link_facebook flag.
      get :update, :link_facebook => '1'
    end
    
    assert_response :success
    assert_template 'edit'
    @quentin.reload
    assert !@quentin.linked_to_facebook?
    assert_nil @quentin.facebook_uid
    assert_nil @quentin.facebook_access_token
    assert !@quentin.facebook_post_ideas
  end
  
  def test_unlink_facebook
    # unlink requires pass
    @facebooker.password = @facebooker.password_confirmation = 'pass'
    @facebooker.save!
    
    assert_login_required @facebooker do
      post :update, :user => { :zip_code => '12345' }, :unlink_facebook => 'Button name'
    end
    
    @facebooker.reload
    assert_equal '12345', @facebooker.zip_code
    assert !@facebooker.linked_to_twitter?
    assert !@facebooker.facebook_post_ideas
  end
  
  def test_unlink_facebook_bypassed_if_form_errors
    # unlink requires pass
    @facebooker.password = @facebooker.password_confirmation = 'pass'
    @facebooker.save!
    
    login_as @facebooker
    post :update, :user => { :password => 'mis', :password_confirmation => 'match' }, :unlink_facebook => 'Button name'
    
    @facebooker.reload
    assert @facebooker.linked_to_facebook?
    assert @facebooker.facebook_post_ideas
  end
  
  protected
    def create_user(options = {})
      post :create, :user =>
        {
          :name => 'S. Quire',
          :email => 'quire@example.com',
          :zip_code => '55402',
          :password => 'quire',
          :password_confirmation => 'quire',
          :terms_of_service => '1'
        }.merge(options)
    end
    
    def current_user
      session[:user_id] ? User.find(session[:user_id]) : nil
    end
    
    def logged_in?
      !current_user.nil?
    end
    
    def assert_email_sent(user, *body_pats)
      fail "Expected email to have been sent by controller" if @deliveries.empty?
      sent = @deliveries.shift
      assert_equal [user.email], sent.to
      body_pats.each do |body_pat|
        assert sent.body =~ body_pat, "Expected #{body_pat.inspect} in email body, but didn't find it.\n\nEmail body:\n\n#{sent.body}\n"
      end
    end
    
    def assert_account_activated_immediately
      user = current_user
      assert user.active?
      assert !(flash[:info] =~ /#{user.email}/)
      assert_equal 1, @deliveries.size
      assert_email_sent user, /account has been activated/
    end
end
