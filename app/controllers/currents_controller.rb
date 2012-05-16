class CurrentsController < ApplicationController

  
  require "#{RAILS_ROOT}/app/jobs/NotificationCurrentJob.rb"
  
  layout :compute_layout
  
  def compute_layout
    if action_name == "index" || action_name == "show" || action_name == "followers"
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
      redirect_to params[:index] ? :back : current_path(@current)
      Delayed::Job.enqueue NotificationCurrentJob.new(current_user, @current)
   
    rescue
      flash[:notice] = "You have successfully followed the idea"
      redirect_to params[:index] ? :back : current_path(@current)
    end  
  end
  
  
  def followers
    @current = Current.find(params[:id])
    @followers=@current.current_followers
    @users=[]
    @followers.each do |f|
      @users << f.user if !@users.include?(f.user)
    end
    page = 1 || params[:page]
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
