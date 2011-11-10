class IdeaPostedFollowerJob 

attr_accessor :user_id, :comment_id
  
  def initialize(user, comment)
    @user_id = user.id
    @comment_id = comment.id
  end

  def perform
    user = User.find(user_id)
    comment = Comment.find(comment_id)
    UserMailer.deliver_idea_posted_to_followers(user,idea)
  end    
end  
