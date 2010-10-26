# This controller handles login/logout functionality.
class SessionsController < ApplicationController
  
  include AuthenticatedSystem
  include TwitterHelper

  def new
    @body_class = 'login'
  end
  
  def new_twitter
    redirect_to twitter_auth_request_url(create_twitter_session_url)
  end

  def create
    user = User.find_by_login(params[:email], params[:password])
    if user
      self.current_user = user
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      response_for_successful_login
    else
      flash.now[:error] = render_to_string :partial => 'login_failed'
      render :action => 'new'
    end
  end
  
  def create_twitter
    credentials = verify_twitter_authorization
    unless credentials.blank?
      if user = User.find_by_twitter_handle(credentials.screen_name)
        self.current_user = user
        
        # Credentials can change if user deauthorizes us, then reauthorizes
        user.twitter_token = twitter_oauth.access_token.token
        user.twitter_secret = twitter_oauth.access_token.secret
        user.save!
        
        response_for_successful_login
      else
        redirect_to new_user_path(
          :user => {
            :name => credentials.name,
            :twitter_handle => credentials.screen_name,
            :twitter_token  => twitter_oauth.access_token.token,
            :twitter_secret => twitter_oauth.access_token.secret })
      end
    else
      flash.now[:info] = "Twitter login canceled."
      redirect_to login_path
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:info] = "You are now logged out. Thanks for using #{SHORT_SITE_NAME}!"
    redirect_back_or_default('/')
  end
  
private
  
  def response_for_successful_login
    redirect_back_or_default do
      if current_user.active?
        redirect_to '/'
      else
        render :action => 'inactive'
      end
    end
  end

end
