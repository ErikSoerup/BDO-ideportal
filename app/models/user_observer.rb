class UserObserver < ActiveRecord::Observer
  
  def after_create(user)
   UserMailer.deliver_signup_notification(user) if user.activation_code
  end

  def after_save(user)
    if user.recently_activated?
      user.count_votes
      UserMailer.deliver_activation(user)
    end
    if user.active?
      UserMailer.deliver_password_change_notification(user)              if user.crypted_password_changed?
      UserMailer.deliver_email_change_notification(user, user.email_was) if user.email_changed?
    end
  end
  
end
