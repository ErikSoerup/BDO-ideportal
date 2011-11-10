class IdeaPostedFollowerJob < Struct.new(:user, :idea)
  def perform
    UserMailer.deliver_idea_posted_to_followers(user,idea)
  end    
end  
