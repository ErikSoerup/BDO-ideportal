# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  
  include SearchHelper
  include ActionView::Helpers::JavaScriptHelper

  def logged_in?
    !current_user.nil?
  end
  def url_field(val)
    "/home/advance?val="+val
  end 


  def next_idea(idea,val=nil)
    if val == "hot"
      ideas = Idea.populate_comment_counts(Idea.find(:all, :include => [{:inventor => :postal_code}, :tags], :conditions => ['users.state = ? and ideas.hidden = ? and ideas.duplicate_of_id is null', 'active', false], :order => 'ideas.rating DESC, ideas.created_at DESC'))
      ideas[ideas.index(idea) + 1]
    elsif val == "recent"
      ideas = Idea.populate_comment_counts(Idea.find(:all, :include => [{:inventor => :postal_code}, :tags], :conditions => ['users.state = ? and ideas.hidden = ? and ideas.duplicate_of_id is null', 'active', false], :order => 'ideas.created_at DESC'))
      ideas[ideas.index(idea) + 1]
    else
      Idea.active.find(:last, :conditions => ["ideas.id > ?", idea.id], :order => "ideas.id DESC")
    end
  end

  def prev_idea(idea,val)
    if val == "hot"
       ideas = Idea.populate_comment_counts(Idea.find(:all, :include => [{:inventor => :postal_code}, :tags], :conditions => ['users.state = ? and ideas.hidden = ? and ideas.duplicate_of_id is null', 'active', false], :order => 'ideas.rating DESC, ideas.created_at DESC'))
      ideas[ideas.index(idea) - 1]
    elsif val == "recent"
      ideas = Idea.populate_comment_counts(Idea.find(:all, :include => [{:inventor => :postal_code}, :tags], :conditions => ['users.state = ? and ideas.hidden = ? and ideas.duplicate_of_id is null', 'active', false], :order => 'ideas.created_at DESC'))
      ideas[ideas.index(idea) - 1]
    else
      Idea.active.find(:first, :conditions => ["ideas.id < ?", idea.id], :order => "ideas.id DESC")
    end
    
  end
 
  def user_formatted_text(text)
    # Handles free-form text for ideas and comments.
    # We could drop in some more elaborate formatting rules here if we want to,
    # but be careful about XSS attacks!
    auto_link(h(text).strip.gsub(/(\n|\r\n|\r)/, '<br/>'), :urls, {:rel => 'nofollow'})
  end

  def idea_owner?(idea)
    logged_in? && current_user.id == idea.inventor_id
  end

  def has_voted?(idea)
    # Cache all ideas voted on by this user to avoid doing O(n) queries
    @voted_for_idea_ids ||= if current_user
      Vote.find(:all, :conditions => {:user_id=>current_user.id}, :select=>'votes.idea_id').map{|x| x.idea_id}
    else
      []
    end

    logged_in? && (idea_owner?(idea) || @voted_for_idea_ids.include?(idea.id))
  end

  def flagged_as_inappropriate?(model)
    session[flagged_as_inappropriate_session_key(model)]
  end

  def flagged_as_inappropriate(model)
    session[flagged_as_inappropriate_session_key(model)] = true
  end

  def ideax_in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {})
    in_place_editor_options.reverse_merge!(
      :save_text => 'Save',
      :cancel_text => 'Cancel',
      :options => '{}, highlightcolor: "#FFFFFF"')  # This is a nasty hack to disable the highlight, but it works
    in_place_editor_field(object, method, tag_options, in_place_editor_options)
  end

  # Path to full-page map for given ideas
  def map_ideas_path(ideas)
    map_path(:idea_ids => ideas.map{ |idea| idea.id }.join(' '))
  end

  def profile_picture(user,options=:small)
    unless user.avatar?
      return '/images/default-avatar-128.png' if options == :large
      return '/images/default-avatar-80.png' if options == :small
    end
    return user.avatar.url(options)
  end

  # IE doesn't fire onchange for checkboxes until blur. This helper method repeats a JS action
  # for change, click, and keypress actions so that checkboxes respond immediately in any browser.
  def check_box_onchange(action, opts = {:onchange => true})
    if opts[:onchange]
      { :onclick => action, :onkeypress => action, :onchange => action }
    else
      { :onclick => action, :onkeypress => action }
    end
  end

  def rss_date(time)
    time.strftime '%a, %d %b %Y %H:%M:%S %z'
  end

  def author_link_of(idea)

  end

  def xml_pagination_attrs(p)
    { 'first-index' => (p.current_page-1) * p.per_page,
      'page-size' => p.per_page,
      'count' => p.size,
      'total-count' => p.total_entries }
  end

  private

  def flagged_as_inappropriate_session_key(model)
    "xxx:#{model.class}:#{model.id}"
  end

  DEFAULT_MAP_CENTER = [39.232253, -96.503906]
  DEFAULT_MAP_ZOOM = 4
  DEFAULT_MINIMAP_ZOOM = 2

end
