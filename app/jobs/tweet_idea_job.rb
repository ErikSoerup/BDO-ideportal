require 'twitter'

class TweetIdeaJob < ShareIdeaJob
  
  def share_idea(idea)
    if !idea.inventor.linked_to_twitter?
      logger.info "Canceling #{self.class} for Idea##{idea.id}, because User##{idea.inventor.id} is no longer linked to Twitter"
      return
    end
    
    twitter_oauth.authorize_from_access(idea.inventor.twitter_token, idea.inventor.twitter_secret)
    twitter = Twitter::Base.new(twitter_oauth)
    
    prefix = "Idea for #{COMPANY_NAME}: "
    suffix = ' ' + idea_url
    message = (
      prefix +
      truncate(idea.title, :length => 140 - prefix.length - suffix.length, :separator => ' ') +
      suffix)
    
    twitter.update message
  end
  
  include TwitterHelper
  
end
