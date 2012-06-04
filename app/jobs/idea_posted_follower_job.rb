
class IdeaPostedFollowerJob

 attr_accessor :user, :idea

  def initialize(users,idea)
     @user = users
     
     @idea = idea
     @idea= Idea.find(@idea.id)
     UserMailer.deliver_idea_posted_to_followers(@user,@idea)
   end

  def perform
     #UserMailer.deliver_idea_posted_to_followers(@user,@idea)
  end
end

