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
  
  def page_title
    if @current
      @current.title
    else
      "Idea Currents"
    end
  end
  
  include ApplicationHelper
  
end