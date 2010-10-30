module TwitterHelper
  
  def twitter_oauth
    @twitter_oauth ||= Twitter::OAuth.new(
      TWITTER_CONFIG['key'],
      TWITTER_CONFIG['secret'],
      :sign_in => true)
  end
  
  def twitter_auth_request_url(url)
    twitter_oauth.set_callback_url(url)
    
    session['rtoken']  = twitter_oauth.request_token.token
    session['rsecret'] = twitter_oauth.request_token.secret
    
    twitter_oauth.request_token.authorize_url
  end
  
  def verify_twitter_authorization
    # In this case, we do actually want to run authorize_from_request and verify_credentials synchronously,
    # so that the user doesn't get through the Twitter linking process until it's succeeded.
    
    # TODO: Do we need any additional handling for auth errors?
    
    rtoken, rsecret = session['rtoken'], session['rsecret']
    return nil unless rtoken && rsecret && params[:denied].blank?
    
    twitter_oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])
    
    session['rtoken']  = nil
    session['rsecret'] = nil
    
    Twitter::Base.new(twitter_oauth).verify_credentials
  end

end
