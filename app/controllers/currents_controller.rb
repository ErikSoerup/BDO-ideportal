class CurrentsController < ApplicationController

  
  require "#{RAILS_ROOT}/app/jobs/NotificationCurrentJob.rb"
  
  layout :compute_layout
  
  def compute_layout
    if action_name == "index" || action_name == "show"
      'profile'
    else
      'application'
    end
  end
  
  make_resourceful do
    actions :show, :index

    before :show do
      @current_ideas = search_ideas(params.merge(:search => ['current', current_object.id]))
    end

    response_for :show do |format|
      format.html
      #format.xml   # for future expansion
      # current/show rss currently supported via /ideas/search/current/<ID>?format=rss
    end
  end

  def current_objects
    @currrents ||= Current.find(:all, :conditions=>"id != #{Current::DEFAULT_CURRENT_ID}")
  end


  def page_title
    if @current
      @current.title
    else
      t("idea_current")
    end
  end

  def change_subscription(enabled)
    @current = current_object
    if enabled
      @current.subscribers << current_user
    else
      @current.subscribers.delete current_user
    end

    respond_to do |format|
      format.html do
        flash[:info] = 'You are no longer subscribed to notifications of new ideas on this current.' if !enabled
        redirect_to :action => 'show'
      end
      format.js do
        render :partial => 'subscription'
      end
    end
  end

  def follow
    
    begin
      @current= Current.find(params[:current_id])
      CurrentFollower.create!(:user_id => current_user.id, :current_id => @current.id)
      flash[:notice] = "You have successfully followed the idea"
      redirect_to current_path(@current)
      Delayed::Job.enqueue NotificationCurrentJob.new(current_user, @current)
   
    rescue
      flash[:notice] = "You have successfully followed the idea"
      redirect_to current_path(@current)
    end  
  end
  
  
  def followers
    @current=Current.find(params[:id])
    @followers=@current.current_followers
    @users=[]
    @followers.each do |f|
      @users << f.user
    end
  end
  def unfollow
    @current_follow=CurrentFollower.find_by_user_id_and_current_id(current_user.id,params[:id])
    @current_follow.destroy unless @current_follow.nil? 
    flash[:notice] = "Your fellowship of this idea has been removed"
    redirect_to currents_path
  end
  
  
  def subscribe
    change_subscription(true)
  end

  def unsubscribe
    change_subscription(false)
  end

  include ApplicationHelper

end
