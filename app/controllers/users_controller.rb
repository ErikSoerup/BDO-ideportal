class UsersController < ApplicationController
  include AuthenticatedSystem
  
  before_filter :login_required, :only => [:edit, :update, :authorize_twitter]
  before_filter :populate_user, :except => [:show]

  def new
    if params[:user] && params[:user][:twitter_token]
      new_user_from_params
      render :action => 'new_via_twitter'
    else
      render :action => 'new'
    end
  end

  def create
    cookies.delete :auth_token
    new_user_from_params
    if @user.valid?
      @user.save!
      @user.register!
      @user.activate! if @user.linked_to_twitter?
      self.current_user = @user
      flash[:info] = render_to_string(:partial => 'created')
      redirect_back_or_default('/')
    else
      if @user.twitter_token
        render :action => 'new_via_twitter'
      else
        render :action => 'new'
      end
    end
  end

  def activate
    if log_in_with_activation_code
      flash[:info] = "Your account is now activated!"
      redirect_back_or_default('/')
    else
      render :action => 'bad_activation_code'
    end
  end
  
  def send_activation
    @user = User.find_by_email(params[:email])
    raise "No such user" unless @user
    @user.reset_activation_code unless @user.activation_code
    UserMailer.deliver_signup_notification(@user)
    flash[:info] = render_to_string(:partial => 'created')
    redirect_back_or_default('/')
  end

  def forgot_password
  end
  
  def send_password_reset
    if params[:email].blank?
      @missing = true
    else
      user = User.find_by_email(params[:email])
      if user
        user.reset_activation_code
        user.save!
        UserMailer.deliver_password_reset(user)
        return render(:action => 'password_reset_sent')
      else
        @not_found = true
      end
    end
    render :action => 'forgot_password'
  end
  
  def new_password
    if log_in_with_activation_code
      flash[:info] = "Please choose a new password."
      redirect_to :action => 'edit'
    else
      render :action => 'bad_activation_code'
    end
  end
  
  def edit
    render :action => 'edit'
  end
  
  def update
    # TODO: Should we require confirmation process if email changes?
    @user.update_attributes(params[:user])
    unlink_twitter if params[:unlink_twitter]
    
    if @user.save
      flash.now[:info] = "Your changes have been saved."
      @user.password = @user.password_confirmation = nil
      
      if params[:link_twitter]
        redirect_to twitter_auth_request_url(authorize_twitter_url)
        return
      end
    end
    
    render :action => 'edit'
  end
  
  def authorize_twitter
    credentials = verify_twitter_authorization
    if credentials
      @user.twitter_token = twitter_oauth.access_token.token
      @user.twitter_secret = twitter_oauth.access_token.secret
      @user.twitter_handle = credentials.screen_name
      @user.tweet_ideas = true
      
      if @user.save
        flash.now[:info] = "Your IdeaX account is now linked to Twitter."
      end
    else
      flash.now[:info] = "Twitter authorization canceled."
    end
    
    redirect_to edit_user_path
  end
  
  def disconnect
    if current_user.is_facebook_user?
      current_user.fb_uid = nil
      if current_user.save
        flash[:notice] = 'Your account has been disconnected from facebook'
      end
    end
    render :action => 'edit'
  end
  
  include TwitterHelper
  
protected

  def populate_user
    @user = current_user
  end
  
  def new_user_from_params
    @user = User.new(params[:user])
    @user.twitter_token = params[:user][:twitter_token]
    @user.twitter_secret = params[:user][:twitter_secret]
    @user.twitter_handle = params[:user][:twitter_handle]
  end
  
  def log_in_with_activation_code
    unless params[:activation_code].blank?
      code = params[:activation_code].gsub(/[^\w]/, '')  # Remove any whitespace/garbage the user accidentally copied
      self.current_user = User.find_by_activation_code(code)
      if logged_in? && !current_user.active?
        current_user.activate!
      end
    end
    logged_in?
  end
  
  def unlink_twitter
    @user.twitter_token = @user.twitter_secret = @user.twitter_handle = nil
    @user.tweet_ideas = false
  end

end
