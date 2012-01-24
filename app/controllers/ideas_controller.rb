require 'timeout'

class IdeasController < ApplicationController

  # Authentication
  before_filter :login_required
  #, :except => [:index, :show, :create]      # create not included here b/c it will redirect to login page AFTER saving
  before_filter :oauthenticate, :unless => :logged_in?                    # If no other login was applied, use oauth if present (even for index/show/create)

  # Authorization
  before_filter :check_visibility, :only => [:show]
  before_filter :check_ownership, :only => [:update]

  # Content cleanup & population
  before_filter :strip_example_text
  before_filter :add_search_feed, :only => :index
  before_filter :add_comments_feed, :only => [:show, :update]
  layout 'profile'

  def compute_layout
    if action_name == "index" && !params[:search].nil? || action_name == "show" || action_name == "new"
      'profile'
    else
      'application'
    end
  end

  param_accessible :idea => [:title, :description, :tag_names, :current_id, :document ]

  make_resourceful do
    actions :new, :create, :show, :update, :destroy

    before :create do
      @idea.inventor = current_user
      @idea.ip = request.remote_ip
      @idea.user_agent = request.user_agent
      if params[:tags]
        # User can enter tags as free-form text, or using client-side JS. We need to merge tags from the two sources.
        @idea.tags += params[:tags].values.map{ |tag| Tag.from_string(tag) }.flatten
      end
    end



    after :create do

      if @idea.valid? && @idea.inventor
        # Users automatically vote for their own ideas:
        @idea.add_vote!(@idea.inventor)
        if @idea.current && !@idea.current.current_followers.empty?
          @idea.current.current_followers.each do |follow|
            Delayed::Job.enqueue IdeaNotificationJob.new(User.find(follow.user_id), @idea) unless User.find(follow.user_id) == current_user
          end
          #Delayed::Job.enqueue IdeaPostedFollowerJob.new(@idea.inventor, @idea)
        end

        if TWITTER_ENABLED && @idea.inventor.linked_to_twitter? && @idea.inventor.tweet_ideas?
          Delayed::Job.enqueue TweetIdeaJob.new(@idea, idea_url(@idea, :title_in_url => false))
        end

        if FACEBOOK_ENABLED && @idea.inventor.linked_to_facebook? && @idea.inventor.facebook_post_ideas?

          # Facebook regularly expires its access tokens. We attach the last one we got the user, but
          # if they're not currently logged in to Facebook, there's no guarantee it will work. So we delay
          # our attempt to post to FB unless we were able to get an up-to-date access token on this request.
          #
          # Once it fires, the Facebook post may fail. However, Delayed::Job will keep reattempting the
          # Facebook post over a period of time until it succeeds, so it's OK if the user doesn't log back
          # in to Facebook immediately.
          first_post_attempt_at = 2.minutes.from_now

          if !current_facebook_user
            flash[:info] = render_to_string(:partial => 'facebook_log_in_to_post_idea')
          elsif current_facebook_user.id != current_user.facebook_uid
            flash[:info] = render_to_string(:partial => 'facebook_switch_account_to_post_idea')
          else
            # We're logged in as the correct user on Facebook, so update_facebook_access_token in the
            # app controller has presumably brought our facebook access token up to date, and we
            # can start trying to post immediately without waiting for a login.
            first_post_attempt_at = Time.now
          end

          Delayed::Job.enqueue FacebookPostIdeaJob.new(@idea, idea_url(@idea)), 0, first_post_attempt_at.getutc
        end
      end
    end

    response_for :show do |format|
      format.html
      format.xml
    end

    response_for :create do |format|
      format.html do
        if @idea.inventor
          redirect_to idea_path(@idea)
        else
          login_required assign_idea_path(@idea), :post
        end
      end
      format.js do
        if @idea.inventor
          render :template => 'generalized_redirect', :layout => false,
            :locals => { :redirect_path => idea_path(@idea), :message => 'Creating idea...' }
        else
          login_required assign_idea_path(@idea), :post
        end
      end
      format.xml do
        render :template => 'ideas/show'
      end
    end

    response_for :create_fails do |format|
      format.html { render :template => 'ideas/new' }
      format.js   { render :partial => 'new' }
      format.xml  { render :template => 'validation_errors' }
    end



    response_for :update do |format|
      format.html do
        redirect_to idea_path(@idea)
      end
      format.js do
        render :template => 'generalized_redirect', :layout => false,
          :locals => { :redirect_path => idea_path(@idea), :message => 'Updating idea...' }
      end
    end

    response_for :update_fails do |format|
      format.js { render :partial => 'edit' }
    end

  end

  # Assigns the owner of an orphaned idea after the user has logged in.
  def assign
    Idea.transaction do
      @idea = current_object
      @idea.lock!
      @idea.inventor ||= current_user
      @idea.save!
      @idea.add_vote!(@idea.inventor)
    end
    redirect_to idea_path(@idea)
  end


  def destroy_idea
    @idea=Idea.find(params[:id])
    @idea.destroy
    render :layout => false
  end




  def follow
    begin
      @idea= Idea.find(params[:idea_id])
      IdeaFollower.create!(:user_id => current_user.id, :idea_id => @idea.id)
      flash[:notice] = "You have successfully followed the idea"
      redirect_to idea_path(@idea)
      Delayed::Job.enqueue NotificationCommentJob.new(current_user, @idea)
      #      UserMailr.deliver_notification_comments()
    rescue
      flash[:notice] = "You have successfully followed the idea"
      redirect_to idea_path(@idea)
    end
  end


  def followers
    @body_class='advance'
    page = 1 || params[:page]
    @idea=Idea.find(params[:id])
    @users=@idea.idea_followers.collect(&:user).uniq

    if params[:val]
      @users=@users.find_all {|user|  user.name.first == params[:val].to_s}

    elsif params[:name] == "navn" &&  params[:arrow] =="up"

      @users=@users.sort{|x,y| x.name <=> y.name}
    elsif params[:name] == "navn" &&  params[:arrow] == "down"
      @users=@users.sort{|x,y| y.name <=> x.name}
    elsif params[:name] == "afeld" && params[:arrow] == "up"
      @users=@users.sort{|x,y| x.department.name <=> y.department.name}
    elsif params[:name] == "afeld" && params[:arrow] == "down"
      @users=@users.sort{|x,y| y.department.name <=> x.department.name}
    elsif params[:name] == "score" && params[:arrow] == "up"
      @users=@users.sort{|x,y| x.contribution_points <=> y.contribution_points}
    elsif params[:name] == "score" && params[:arrow] == "down"
      @users=@users.sort{|x,y| y.contribution_points <=> x.contribution_points}
    elsif params[:name] == "idea" && params[:arrow] == "up"
      @users=@users.sort{|x,y| x.ideas.size <=> y.ideas.size}
    elsif params[:name] == "idea" && params[:arrow] == "down"
      @users=@users.sort{|x,y| y.ideas.size <=> x.ideas.size}
    elsif params[:name] == "comment" && params[:arrow] == "up"
      @users=@users.sort{|x,y| x.comments.size <=> y.comments.size}
    elsif params[:name] == "comment" && params[:arrow] == "down"
      @users=@users.sort{|x,y| y.comments.size <=> x.comments.size}
    elsif params[:name] == "comment" && params[:arrow] == "up"
      @users=@users.sort{|x,y| x.votes.size <=> y.votes.size}
    elsif params[:name] == "comment" && params[:arrow] == "down"
      @users=@users.sort{|x,y| y.votes.size <=> x.votes.size}
    else
      @users = @users
    end
    @users=@users.paginate :page => page unless @users.nil?

  end
  def unfollow
    @idea_follow=IdeaFollower.find_by_user_id_and_idea_id(current_user.id,params[:id])
    @idea_follow.destroy unless @idea_follow.nil?
    flash[:notice] = "Your fellowship of this idea has been removed"
    redirect_to ideas_path
  end


  def index
    unless params[:status].nil?



      current_objects(params[:status])
    else
      if params[:page_size]
        page_size = params[:page_size].to_i
        params[:page_size] = 1 if page_size < 1
        params[:page_size] = 50 if page_size > 50
      end

      # Call current_objects to populate @body_class. (If the results are cached, we don't need to do this.
      # We never cache the idea list for a user who is logged in, because we want their votes to show up immediately.)
      unless !logged_in? && fragment_exist?(['idea_search', CGI.escape(params.inspect)])
        current_objects()
      end
    end
    respond_to do |format|
      format.html
      format.js
      format.rss { render :content_type => 'application/rss+xml'}
      format.xml
    end
  end

  def change_subscription(enabled)
    @idea = current_object
    if enabled
      @idea.subscribers << current_user
    else
      @idea.subscribers.delete current_user
    end

    respond_to do |format|
      format.html do
        if !enabled
          if current_user == @idea.inventor && current_user.notify_on_comments?
            flash[:info] = 'To stop receiving email notifications when people comment on ideas you invented, uncheck the notification box below.'
            redirect_to edit_user_path
          else
            flash[:info] = 'You are no longer subscribed to notifications of new comments on this idea.'
            redirect_to :action => 'show'
          end
        else
          redirect_to :action => 'show'
        end
      end

      format.js do
        render :partial => 'subscription'
      end
    end
  end

  def subscribe
    change_subscription(true)
  end

  def unsubscribe
    change_subscription(false)
  end

  def current_objects(status = nil)
    if status.nil?
      @currents ||= Idea.populate_comment_counts(search_ideas(params))
    else
      @currents ||= Idea.paginate(:per_page => 8,:page => params[:page], :conditions =>["status = ?",status])
    end
  end

  def check_visibility
    @idea = current_object
    resource_gone unless @idea.visible? || logged_in? && @idea.inventor_id == current_user.id
  end

  def check_ownership
    raise "Cannot modify idea you did not create" if !idea_owner?(current_object)
  end

  def add_search_feed
    if params[:search]
      current_objects
      @feeds << {
        :href => idea_search_url(params[:search], :format => 'rss'),
        :title => "#{LONG_SITE_NAME}: #{ERB::Util.h @query_title}" }
    end
  end

  def add_comments_feed
    @feeds << {
      :href => idea_comments_url(current_object, :format => 'rss'),
      :title => "#{LONG_SITE_NAME}: Comments on \"#{ERB::Util.h(ERB::Util.h current_object.title)}\"" }
  end

  def page_title
    if @idea && !@idea.title.blank?
      @idea.title
    else
      @query_title
    end
  end

  include ApplicationHelper
  helper_method :has_voted?
  helper_method :idea_owner?
  helper_method :flagged_as_inappropriate?

  private

  # In case Javascript failed to remove example text (IE has trouble with this), we strip it here.
  # example_text.js appends \xA0 (a non-breaking space) to distinguish example text. If we see that
  # on a param, out it goes!
  def strip_example_text
    if params[:idea]
      params[:idea].each_key do |key|
        params[:idea][key] = '' if params[:idea][key] =~ /\xA0$/
      end
    end
  end

end
