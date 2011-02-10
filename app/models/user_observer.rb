class UserObserver < ActiveRecord::Observer
  
  def after_create(user)
   UserMailer.deliver_signup_notification(user) if user.activation_code
  end
  
  def before_save(user)
    if user.notify_on_comments_changed? && !user.notify_on_comments?
      # Alas, ActiveRecord association doesn't understand delete_if.
      user.subscribed_ideas = user.subscribed_ideas.reject do |idea|
        user == idea.inventor
      end
    end
  end

  def after_save(user)
    if user.recently_activated?
      user.count_votes
      user.ideas.each    { |i| i.notify_subscribers! }
      user.comments.each { |c| c.notify_subscribers! }
      UserMailer.deliver_activation(user)
    end
    if user.active?
      UserMailer.deliver_password_change_notification(user)              if user.crypted_password_changed?
      UserMailer.deliver_email_change_notification(user, user.email_was) if user.email_changed?
    end
  end
  
end
