module TwitterHelper
  
  def twitter_oauth
    @twitter_oauth ||= Twitter::OAuth.new(
      ENV['TWITTER_API_KEY']    || TWITTER_CONFIG['key'],
      ENV['TWITTER_API_SECRET'] || TWITTER_CONFIG['secret'],
      :sign_in => true)
  end
  
end
