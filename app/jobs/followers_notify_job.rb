class FollowersNotifyJob

  attr_accessor :user_ids, :idea_id

  def initialize(user, idea)
    @user_ids = user.id
    @idea_id = idea.id
  end

  def perform
    users = User.find(user_ids)
    idea = Idea.find(idea_id)
    #later need to process it in batch
    UserMailer.deliver_idea_posted_to_followers(user, idea)
  end

end
