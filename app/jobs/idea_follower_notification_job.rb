class IdeaFollowerNotificationJob

  attr_accessor :follower, :followed

  def initialize(users,idea)
    @user = users

    @idea = idea
    @idea= Idea.find(@idea.id)
    UserMailer.deliver_idea_followers_notification(@user, @idea)
    UserMailer.deliver_idea_followed_notification(@user, @idea)
  end

  def perform
  end
  
end
