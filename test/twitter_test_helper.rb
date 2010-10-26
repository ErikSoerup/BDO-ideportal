require 'mocha'

module TwitterTestHelper
  
  MOCK_TWITTER_AUTH_URL = "http://twitter/auth/url"
  
  def expect_twitter_auth_request
    Twitter::OAuth.any_instance.expects(:request_token).at_least_once.
      with { |*args| @twitter_callback = args[0][:oauth_callback] unless args.empty?; true }.
      returns(stub(:token => 'foo', :secret => 'bar', :authorize_url => MOCK_TWITTER_AUTH_URL))
  end
  
  def assert_twitter_redirect_with_callback(callback)
    assert_redirected_to MOCK_TWITTER_AUTH_URL
    assert_equal callback, @twitter_callback
    assert_equal 'foo', session['rtoken']
    assert_equal 'bar', session['rsecret']
  end
  
  def expect_twitter_auth_verificiation(screen_name)
    session['rtoken'] = 'tw_rtoken'
    session['rsecret'] = 'tw_rsecret'
    
    Twitter::OAuth.any_instance.expects(:authorize_from_request).once.with('tw_rtoken', 'tw_rsecret', 'tw_verify')
    Twitter::OAuth.any_instance.expects(:access_token).at_least_once.returns(stub(:token => 'tw_token', :secret => 'tw_secret'))
    Twitter::Base.any_instance.expects(:verify_credentials).once.returns(stub(:screen_name => screen_name))
  end
  
  def expect_no_twitter_auth_verification
    Twitter::OAuth.any_instance.expects(:authorize_from_request).never
  end
  
  def twitter_callback(action)
    get action, :oauth_verifier => 'tw_verify'
  end

  def twitter_callback_denied(action)
    get action, :denied => '1'
  end

end
