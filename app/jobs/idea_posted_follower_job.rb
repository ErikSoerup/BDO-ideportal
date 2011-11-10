class IdeaPostedFollowerJob 

 attr_accessor :user, :idea
  
  def initialize(user,idea)
     @user = user
     @idea = idea
     @user = User.find(@user.id)
     @idea= Idea.find(@idea.id)
     UserMailer.deliver_idea_posted_to_followers(@user,@idea)
  end

  def perform
  end    
end  
