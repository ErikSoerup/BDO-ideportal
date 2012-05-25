class NotificationCommentJob

  attr_accessor :user, :idea

  def initialize(users,idea)
    @user = users

    @idea = idea
    @idea= Idea.find(@idea.id)
    #    UserMailer.deliver_notification_followers_comments(@user, @idea)
    UserMailer.deliver_notification_followed_comments(@user, @idea)

    followers = @idea.idea_followers
    followers.each do |f|
      if f.user != users
        UserMailer.deliver_notification_to_all_followers_about_comment(@user, f.user, @idea)
      end
    end
  end

  def perform
  end
end
