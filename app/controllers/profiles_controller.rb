class ProfilesController < ApplicationController
  
  before_filter :populate_user
  layout "profile"
  def populate_user
    @body_class = 'profile'
    @user = User.find(params[:id])
    
    resource_gone unless @user.active? || @user == current_user
  end
  
  def show
    if !params[:tab] && !params[:page]
      session["#{'pagination_'+session[:tab]}"] = nil if session[:tab]
      session[:tab] = nil
    end
    @ideas= @user.ideas.paginate(:page => params[:tab] && params[:tab] == "tab1" && session["#{'pagination_'+params[:tab]}"] ? session["#{'pagination_'+params[:tab]}"] : params[:page], :per_page => 3, :order => "created_at DESC")
    @comments= @user.comments.paginate(:page => params[:tab] && params[:tab] == "tab2" && session["#{'pagination_'+params[:tab]}"] ? session["#{'pagination_'+params[:tab]}"] : params[:page], :per_page => 3, :order => "created_at DESC")
    @votes=@user.votes.paginate(:page => params[:tab] && params[:tab] == "tab3" && session["#{'pagination_'+params[:tab]}"] ? session["#{'pagination_'+params[:tab]}"] : params[:page], :per_page => 10)
    @my_currents = @user.current_followers.collect(&:current)
    @my_ideas = @user.idea_followers.collect(&:idea)
    @my_followers = @user.followers
    if request.xhr?
      session[:tab] = params[:tab]
      render :partial => params[:tab]
    else
      if session[:tab]
        session["#{'pagination_'+session[:tab]}"] = params[:page] if params[:page]
      end
      respond_to do |format|
        format.html
        format.xml
        #      format.js { render :text => render_recent(params) }
      end
    end
  end
  
  def my_followers
    @my_followers = @user.following
    render :update do |page|
      page["headline"].replace_html render :partial => "follow_link"
      page["ajax-load"].replace_html render :partial => "my_followers" 
    end

  end
  
  def current_ideas
    @my_ideas = @user.idea_followers.collect(&:idea)
    render :update do |page|
      page["headline"].replace_html render :partial => "idea_link"
      page["ajax-load"].replace_html render :partial => "current_ideas" 
    end
  end
  
  
  def current_currents
    @my_currents = @user.current_followers.collect(&:current)
    render :update do |page|
      page["headline"].replace_html render :partial => "current_link"
      page["ajax-load"].replace_html render :partial => "current_currents" 
    end
  end
  
  
  def render_recent(params)
    model = params[:recent]
    collection, partial = case model
    when 'ideas'    then [@user.ideas,    'ideas/idea']
    when 'comments' then [@user.comments, 'comments/comment']
    when 'votes'    then [@user.votes,    'vote']
    else raise 'Invalid value for "recent" param'
    end
    
    render_to_string :partial => 'recent', :locals => {
      :model => model,
      :collection => collection,
      :offset => params[:offset].to_i,
      :limit  => params[:limit].to_i,
      :partial => partial }
  end
  helper_method :render_recent
  
  def page_title
    "User Profile: #{@user.name}" if @user
  end
    
end
