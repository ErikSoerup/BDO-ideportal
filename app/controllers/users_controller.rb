class UsersController < ApplicationController
  include AuthenticatedSystem

  before_filter :login_required, :only => [:index, :edit, :update, :authorize_twitter, :following, :follow]
  before_filter :populate_user, :except => [:show, :new]
  before_filter :get_user, :only => [:following, :followers]

  def index
    @body_class='advance'
    page = 1 || params[:page]
    @users = User.find_top_contributors(true).paginate :page => page
  end


  def new
    if params[:user] && params[:user][:twitter_token] || params[:facebook_create]
      new_user_from_params
      @user.tweet_ideas = @user.linked_to_twitter?
      @user.facebook_post_ideas = @user.linked_to_facebook?
      render :action => 'new_via_third_party'
    else
      render :action => 'new'
    end
  end

  def current_ideas
    @ideas = current_user.idea_followers.collect(&:idea)
    
  end
  
  
  def current_currents
    @current_ideas = current_user.current_followers.collect(&:current)
  end
  
  def follow_users
    @users=current_user.followers.paginate(:page => params[:page])
  end
  
  def create
    cookies.delete :auth_token
    new_user_from_params
    if @user.valid?
      @user.save!
      @user.register!
      @user.activate! if @user.linked_to_twitter? || @user.linked_to_facebook?
      self.current_user = @user
      flash[:info] = render_to_string(:partial => 'created')
      redirect_back_or_default('/')
    else
      if @user.linked_to_twitter? || @user.linked_to_facebook?
        render :action => 'new_via_third_party'
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

  def follow
    @following = User.find(params[:id])
    if @following
      current_user.follow!(@following)
      flash[:info] = "You are now following #{@following.name}"
      redirect_to profile_url(@following)
    end
  end

  def unfollow
    @unfollow = User.find(params[:id])
    if @unfollow
      current_user.unfollow!(@unfollow)
      flash[:info] = "You are now unfollowing #{@unfollow.name}"
      redirect_to profile_url(current_user)
    end
  end

  def following
    @show_links = true
    @users= @user.following.paginate :page => @page , :per_page=>10
  end

  def followers
    @users = @user.followers.paginate :page=> @page , :per_page=>10
    render :following
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
    @user.unlink_twitter  if !params[:unlink_twitter].blank?
    @user.unlink_facebook if !params[:unlink_facebook].blank?

    if !params[:link_facebook].blank?
      authorize_facebook
    elsif @user.save
      flash.now[:info] = "Your changes have been saved."
      @user.password = @user.password_confirmation = nil

      if !params[:link_twitter].blank?
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

  def authorize_facebook
    if current_facebook_user
      # The synchronous call to Mogli::User.find also serves to sanity check our access credentials
      @user.facebook_name = Mogli::User.find("me", current_facebook_client).name
      @user.facebook_uid = current_facebook_user.id
      @user.facebook_access_token = current_facebook_client.access_token
      @user.facebook_post_ideas = true

      if @user.save
        flash.now[:info] = "Your IdeaX account is now linked to Facebook."
      end
    else
      flash.now[:info] = "Facebook authorization canceled."
    end
  end

  def page_title
    "Account Management"
  end

  include TwitterHelper

protected

  def get_user
    @body_class="following"
    @page = params[:page] || 1
    @user = User.find(params[:id])
  end

  def populate_user
    @user = current_user
  end

  def new_user_from_params
    @user = User.new(params[:user])
    @user.twitter_token = params[:user][:twitter_token]
    @user.twitter_secret = params[:user][:twitter_secret]
    @user.twitter_handle = params[:user][:twitter_handle]
    if FACEBOOK_ENABLED && current_facebook_user
      @user.facebook_name = params[:user][:facebook_name]
      @user.facebook_uid = current_facebook_user.id
      @user.facebook_access_token = current_facebook_client.access_token
    end
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

end
