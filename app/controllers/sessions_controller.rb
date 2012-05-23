require 'ostruct'

# This controller handles login/logout functionality.
class SessionsController < ApplicationController

  include AuthenticatedSystem
  include TwitterHelper

  
  layout :compute_layout
  
  def compute_layout
    if action_name == "create"
      'profile'
    end
  end
  
  def new
    flash.clear
    @body_class = 'login'
    #    @ip_addr = request.ip
    #    14.97.183.187-- 59.161.24.221-- 59.161.24.221--
    @ip_addr = request.ip == "127.0.0.1" || request.ip == "14.97.236.231" ? "83.151.150.86" : request.ip
    if @ip_addr != "83.151.150.86"
      @message = "Du kan kun logge ind via det interne netværk. Log først på VPN og derefter på ideportalen."
      @authorized_access = false
    else
      @authorized_access = true
    end
    render :new , :layout=>false
  end

  def new_twitter
    redirect_to twitter_auth_request_url(create_twitter_session_url)
  end

  # No need face new_facebook here, because login initiation happens client-side via FB's Javascript API.

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
      @body_class = 'login'
      flash.now[:error] = render_to_string :partial => 'login_failed'
      render :new , :layout=>false
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

  def create_facebook
    if current_facebook_user
      user = User.find_by_facebook_uid(current_facebook_user.id)
      if user
        self.current_user = user

        user.facebook_access_token = current_facebook_client.access_token
        user.save!

        response_for_successful_login
      else
        # current_facebook_user only contains the uid, because it comes straight from the cookie.
        # To get the user's name & email, we need to talk to the FB servers.
        full_facebook_user = Mogli::User.find("me", current_facebook_client)

        redirect_to new_user_path(
          :user => {
            :name  => full_facebook_user.name,
            :email => full_facebook_user.email,
            :facebook_name => full_facebook_user.name },
          :facebook_create => true)
      end
    else
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
      #if current_user.active?
      #redirect_to '/'
      #else
      #render :action => 'inactive'
      #end
      redirect_to '/'
    end
  end

end
