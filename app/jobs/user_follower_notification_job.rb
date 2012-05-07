class UserFollowerNotificationJob

  attr_accessor :follower, :followed

  def initialize(follower, followed)
    @follower = follower

    @followed = followed
    #    @idea= Idea.find(@idea.id)
    UserMailer.deliver_notification_user_follows(@follower, @followed)
    UserMailer.deliver_notification_user_followed(@follower, @followed)
  end

  def perform
  end
  
end
