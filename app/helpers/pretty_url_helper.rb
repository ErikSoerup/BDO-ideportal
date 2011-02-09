module PrettyUrlHelper
  
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
  
  def self.included(base)
    make_pretty_url :idea, :title
    make_pretty_url :profile, :name
    make_pretty_url :current, :title
  end
  
private

  def self.make_pretty_url(model_name, title_method)
    [:path, :url].each do |url_type|
      define_method "#{model_name}_#{url_type}" do |*args|
        model,opts = args
        opts ||= {}
        build_pretty_link model_name, url_type, model, title_method, opts
      end
    end
  end

  def build_pretty_link(model_name, url_type, model, title_method, opts)
    if opts.has_key?(:title_in_url)
      title_in_url = opts[:title_in_url]
      opts.delete :title_in_url
    else
      # Forms sometimes submit to something like idea_path (with no args). In this case, we want @idea
      # as the model, and _not_ the pretty URL (which won't recognize a post).
      title_in_url = !model.nil?
      model ||= instance_variable_get('@' + model_name.to_s)
    end
    
    model_title = model && model.send(title_method)
    model_title = model_title.downcase.gsub("'", '').gsub(/[^a-z0-9 -]/, ' ').gsub(/ +/, '-').gsub(/^-|-$/, '')[0,60]
    model_title = '' if model_title =~ /^[A-Za-z]*$/  # don't use single-word pretty links so that we don't interfere with routing
    
    link = self.send("#{model_name}_pretty_#{url_type}".to_sym, model, model_title, opts)
    
    link.gsub!(/\/#{model_title}($|\?)/, '\1') unless title_in_url
    link
  end
  
end