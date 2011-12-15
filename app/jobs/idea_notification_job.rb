class IdeaNotificationJob
  
  attr_accessor :user_id, :idea_id
  
  def initialize(user, idea)
    @user_id = user.id
    @idea_id = idea.id
    user = User.find(@user_id)
    idea = Idea.find(@idea_id)
    # check again in case we were marked spam after job was schedule
      UserMailer.deliver_idea_in_current_notification(user, idea)
   
  end
  
  def perform
    
  end
  
end
