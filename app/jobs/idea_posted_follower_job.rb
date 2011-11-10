class IdeaPostedFollowerJob

 attr_accessor :user, :idea

  def initialize(users,idea)
     @user = users
     logger.info "__WORKING__"
     @idea = idea
     @idea= Idea.find(@idea.id)
   end

  def perform
     UserMailer.deliver_idea_posted_to_followers(@user,@idea)
  end
end
