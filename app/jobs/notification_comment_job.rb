class NotificationCommentJob

  attr_accessor :user, :idea

  def initialize(users,idea)
    @user = users
     
    @idea = idea
    @idea= Idea.find(@idea.id)
    UserMailer.deliver_notification_followers_comments(@user, @idea)
  end

  def perform
  end
end
