class IdeaNotificationJob

  attr_accessor :user_id, :idea_id

  def initialize(user, idea, for_followers=false)
    @user_id = user.id
    @idea_id = idea.id
  end

  def perform
    user = User.find(user_id)
    idea = Idea.find(idea_id)
    if idea.should_notify_subscribers?  # check again in case we were marked spam after job was schedule
      UserMailer.deliver_idea_in_current_notification(user, idea)
    end
  end

end
