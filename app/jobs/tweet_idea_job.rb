class TweetIdeaJob < ActionController::Base
  
  attr_accessor :idea_id, :idea_url
  
  def initialize(idea, idea_url)
    @idea_id = idea.id
    @idea_url = idea_url  # need to get it here because we don't have access to the idea_url method
  end
  
  def perform
    Timeout::timeout(30) do
      idea = Idea.find(idea_id)
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
  end
  
  include TwitterHelper
  include ActionView::Helpers::TextHelper # for truncate
  
end
