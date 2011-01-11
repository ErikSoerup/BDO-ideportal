require 'ostruct'

class MapsController < ApplicationController

  def show
    @body_class = 'nearby'

    if params[:idea_ids]
      idea_ids = params[:idea_ids].split(/\s+|,/)
      @body_class = nil  # These ideas aren't necessarily nearby
    elsif search = params[:search]
      if search_postal_code = search[:postal_code]
        postal_code = PostalCode.find_by_text(search_postal_code)
      end
    elsif logged_in?
      postal_code = current_user.postal_code
    end
    
    if postal_code
      @search = OpenStruct.new(:postal_code => postal_code.code)
      idea_ids = search_idea_ids_near(postal_code)
    end

    idea_ids ||= []
    ideas = Idea.find(idea_ids, :include => [{:inventor => :postal_code}, :tags])
    
    Idea.populate_comment_counts(ideas)
    @map = map_ideas(ideas)
    
    respond_to do |format|
      format.html
      format.js do
        render :text => @map
      end
    end
  end
  
  def page_title
    "Idea Map"
  end
  
  include ApplicationHelper
end
