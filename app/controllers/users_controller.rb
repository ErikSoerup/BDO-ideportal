class UsersController < ApplicationController
  include AuthenticatedSystem

  before_filter :login_required, :only => [:index, :edit, :update, :authorize_twitter, :following, :follow]
  before_filter :populate_user, :except => [:show, :new]
  before_filter :get_user, :only => [:following, :followers]

  layout 'profile'
  
  def compute_layout
    if action_name == "index" || action_name == "search_user" || action_name == "edit"
      'profile'
    else
      'application'
    end
  end
  
  def index
    @body_class='advance'
    page = 1 || params[:page]
    
    if params[:val]
      @users=User.find_top_contributors(:all, :conditions => ['name like ?', "#{params[:val]}%"])
    elsif params[:value] 
      @users=User.find(:all, :conditions =>"recent_contribution_points is not NULL and state='active' and (select count(*) from roles_users where roles_users.user_id = users.id) = 0", :order => "recent_contribution_points DESC")
    elsif params[:name] == "navn" &&  params[:arrow] =="up"
      
      @users=User.find_top_contributors(:all, :order=>"users.name ASC")
    elsif params[:name] == "navn" &&  params[:arrow] == "down"
      @users=User.find_top_contributors(:all, :order=>"users.name DESC")
    elsif params[:name] == "afeld" && params[:arrow] == "up"
      @users=User.find_top_contributors(:all).sort{|x,y| x.department.name <=> y.department.name}
    elsif params[:name] == "afeld" && params[:arrow] == "down"
      @users=User.find_top_contributors(:all).sort{|x,y| y.department.name <=> x.department.name}
    elsif params[:name] == "score" && params[:arrow] == "up"
      @users=User.find_top_contributors(:all, :order => "users.contribution_points DESC")
    elsif params[:name] == "score" && params[:arrow] == "down"
      @users=User.find_top_contributors(:all, :order => "users.contribution_points ASC")
    elsif params[:name] == "idea" && params[:arrow] == "up"
      @users=User.find_top_contributors(:all).sort{|x,y| x.ideas.size <=> y.ideas.size}
    elsif params[:name] == "idea" && params[:arrow] == "down"
      @users=User.find_top_contributors(:all).sort{|x,y| y.ideas.size <=> x.ideas.size}
    elsif params[:name] == "comment" && params[:arrow] == "up"
      @users=User.find_top_contributors(:all).sort{|x,y| x.comments.size <=> y.comments.size}
    elsif params[:name] == "comment" && params[:arrow] == "down"
      @users=User.find_top_contributors(:all).sort{|x,y| y.comments.size <=> x.comments.size}
    elsif params[:name] == "comment" && params[:arrow] == "up"
      @users=User.find_top_contributors(:all).sort{|x,y| x.votes.size <=> y.votes.size}
    elsif params[:name] == "comment" && params[:arrow] == "down"
      @users=User.find_top_contributors(:all).sort{|x,y| y.votes.size <=> x.votes.size}  
    else
      @users = User.find_top_contributors(true)
    end
    @users=@users.paginate :page => page unless @users.nil?
  end

  def search_user
    @users= User.find(:all, :conditions => ['name like ?', "#{params[:search]}%"])
    @users=@users.paginate :page => params[:page] unless @users.nil?
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
    respond_to do |format|
      format.js { render :layout=>false }
    end

  end
  
  def current_currents
    @current_ideas = current_user.current_followers.collect(&:current)
    respond_to do |format|
      format.js { render :layout=>false }
    end
  end
  
  def follow_users
    @users=current_user.followers.paginate(:page => params[:page])
    respond_to do |format|
      format.js { render :layout=>false }
    end
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
    begin
      @following = User.find(params[:id])
      if @following
        current_user.follow!(@following)
        flash[:info] = "You are now following #{@following.name}"
        redirect_to params[:index] ? :back : profile_url(@following)
      end
      Delayed::Job.enqueue UserFollowerNotificationJob.new(current_user, @following)
      #      UserMailr.deliver_notification_comments()
    rescue Exception => e
      flash[:notice] = "You have successfully followed the idea"
      redirect_to params[:index] ? :back : profile_url(@following)
    end
  end

  def unfollow
    @unfollow = User.find(params[:id])
    if @unfollow
      current_user.unfollow!(@unfollow)
      flash[:info] = "You are now unfollowing #{@unfollow.name}"
      redirect_to params[:index] ? :back : profile_url(@unfollow)
    end
  end

  def following
    @show_links = true
    
    if params[:val]
      @users=@user.following.find_all { |emp| emp.name.first == params[:val].to_s }
      
    elsif params[:name] == "navn" &&  params[:arrow] =="up"
      
      @users=@user.following(:all, :order=>"users.name ASC")
    elsif params[:name] == "navn" &&  params[:arrow] == "down"
      @users=@user.following(:all, :order=>"users.name DESC")
    elsif params[:name] == "afeld" && params[:arrow] == "up"
      @users=@user.following(:all).sort{|x,y| x.department.name <=> y.department.name}
    elsif params[:name] == "afeld" && params[:arrow] == "down"
      @users=@user.following(:all).sort{|x,y| y.department.name <=> x.department.name}
    elsif params[:name] == "score" && params[:arrow] == "up"
      @users=@user.following(:all).sort{|x,y| y.contribution_points <=> x.contribution_points}
    elsif params[:name] == "score" && params[:arrow] == "down"
      @users=@user.following(:all).sort{|x,y| x.contribution_points <=> y.contribution_points}
    elsif params[:name] == "idea" && params[:arrow] == "up"
      @users=@user.following(:all).sort{|x,y| x.ideas.size <=> y.ideas.size}
    elsif params[:name] == "idea" && params[:arrow] == "down"
      @users=@user.following(:all).sort{|x,y| y.ideas.size <=> x.ideas.size}
    elsif params[:name] == "comment" && params[:arrow] == "up"
      @users=@user.following(:all).sort{|x,y| x.comments.size <=> y.comments.size}
    elsif params[:name] == "comment" && params[:arrow] == "down"
      @users=@user.following(:all).sort{|x,y| y.comments.size <=> x.comments.size}
    elsif params[:name] == "comment" && params[:arrow] == "up"
      @users=@user.following(:all).sort{|x,y| x.votes.size <=> y.votes.size}
    elsif params[:name] == "comment" && params[:arrow] == "down"
      @users=@user.following(:all).sort{|x,y| y.votes.size <=> x.votes.size}  
    else
      @users = @user.following.find(:all)
    end
    @users= @users.paginate :page => @page , :per_page=>10
  end

  def followers
    
    if params[:val]
      @users=@user.followers.find_all { |emp| emp.name.first == params[:val].to_s }
      
    elsif params[:name] == "navn" &&  params[:arrow] =="up"
      
      @users=@user.followers(:all, :order=>"users.name ASC")
    elsif params[:name] == "navn" &&  params[:arrow] == "down"
      @users=@user.followers(:all, :order=>"users.name DESC")
    elsif params[:name] == "afeld" && params[:arrow] == "up"
      @users=@user.followers(:all).sort{|x,y| x.department.name <=> y.department.name}
    elsif params[:name] == "afeld" && params[:arrow] == "down"
      @users=@user.followers(:all).sort{|x,y| y.department.name <=> x.department.name}
    elsif params[:name] == "score" && params[:arrow] == "up"
      @users=@user.followers(:all).sort{|x,y| y.contribution_points <=> x.contribution_points}
    elsif params[:name] == "score" && params[:arrow] == "down"
      @users=@user.followers(:all).sort{|x,y| x.contribution_points <=> y.contribution_points}
    elsif params[:name] == "idea" && params[:arrow] == "up"
      @users=@user.followers(:all).sort{|x,y| x.ideas.size <=> y.ideas.size}
    elsif params[:name] == "idea" && params[:arrow] == "down"
      @users=@user.followers(:all).sort{|x,y| y.ideas.size <=> x.ideas.size}
    elsif params[:name] == "comment" && params[:arrow] == "up"
      @users=@user.followers(:all).sort{|x,y| x.comments.size <=> y.comments.size}
    elsif params[:name] == "comment" && params[:arrow] == "down"
      @users=@user.followers(:all).sort{|x,y| y.comments.size <=> x.comments.size}
    elsif params[:name] == "comment" && params[:arrow] == "up"
      @users=@user.followers(:all).sort{|x,y| x.votes.size <=> y.votes.size}
    elsif params[:name] == "comment" && params[:arrow] == "down"
      @users=@user.followers(:all).sort{|x,y| y.votes.size <=> x.votes.size}  
    else
      @users = @user.followers.find(:all)
    end
    
    
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
