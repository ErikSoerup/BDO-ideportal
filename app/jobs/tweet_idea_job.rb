require 'twitter'

class TweetIdeaJob < ShareIdeaJob
  
  def share_idea(idea)
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
