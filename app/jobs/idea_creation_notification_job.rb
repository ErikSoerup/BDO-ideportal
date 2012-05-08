class IdeaCreationNotificationJob

  attr_accessor :user_id, :idea_id

  def initialize(current_user, follower, idea)
    #    @user_id = user.id
    #    @idea_id = idea.id
    #    user = User.find(@user_id)
    #    idea = Idea.find(@idea_id)
    # check again in case we were marked spam after job was schedule
    UserMailer.deliver_idea_creation_notification(current_user, follower, idea)
  end

  def perform

  end

end
