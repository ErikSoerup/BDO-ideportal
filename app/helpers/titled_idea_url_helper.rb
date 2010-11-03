module TitledIdeaUrlHelper
  
  # In most circumstances, we want idea urls/paths that look like this:
  #
  #    http://example.com/ideas/55/here-is-an-idea
  #
  # However, the title portion of the URL is ignored by the server, and is optional. In some cases,
  # we want a shorter and simpler URL (for example, when tweeting an idea or generating a canonical
  # URL for an RSS feed):
  #
  #    http://example.com/ideas/55
  #
  # These methods override the default behavior of idea_url and idea_path to produce the first option
  # by default, but the second if passed :title_in_url => false.
  
  def idea_url(idea = nil, opts = {})
    build_idea_link :titled_idea_url, idea, opts
  end
  
  def idea_path(idea = nil, opts = {})
    build_idea_link :titled_idea_path, idea, opts
  end

private

  def build_idea_link(method, idea, opts)
    if opts.has_key?(:title_in_url)
      title_in_url = opts[:title_in_url]
      opts.delete :title_in_url
    else
      title_in_url = !idea.nil?
      idea ||= @idea
    end
    
    idea_title = idea.title.downcase.gsub(/[^a-z0-9 -]/, '').gsub(/ +/, '-')[0,60]
    
    link = self.send(method, idea, idea_title, opts)
    
    link.gsub!(/\/#{idea_title}/, '') unless title_in_url
    link
  end
  
end