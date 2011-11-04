class CurrentsController < ApplicationController

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

  def suggestions
    @currrent ||= Current.last
    @current_ideas = search_ideas(params.merge(:search => ['current', Current::DEFAULT_CURRENT_ID]))
    render :show
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

  def subscribe
    change_subscription(true)
  end

  def unsubscribe
    change_subscription(false)
  end

  include ApplicationHelper

end
