require 'mogli'

class FacebookPostIdeaJob < ShareIdeaJob
  
  def share_idea(idea)
    if !idea.inventor.linked_to_facebook?
      logger.info "Canceling #{self.class} for Idea##{idea.id}, because User##{idea.inventor.id} is no longer linked to Facebook"
      return
    end
    
    fb_user = Mogli::User.new(
      { :id => idea.inventor.facebook_uid },
      Mogli::Client.new(idea.inventor.facebook_access_token))
    
    fb_user.feed_create(Mogli::Post.new(
      :message => "Idea for #{COMPANY_NAME}: #{idea.title}",
      :description => idea.description,
      :source => idea_url,
      :name => "Vote it up on #{LONG_SITE_NAME}"))
  end
  
end
