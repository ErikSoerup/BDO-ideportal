class CommentNotificationJob
  
  attr_accessor :user_id, :comment_id
  
  def initialize(user, comment)
    @user_id = user.id
    @comment_id = comment.id
  end
  
  def perform
    user = User.find(user_id)
    comment = Comment.find(comment_id)
    UserMailer.deliver_comment_notification(user, comment)
  end
  
end
