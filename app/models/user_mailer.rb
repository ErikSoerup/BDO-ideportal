class UserMailer < ActionMailer::Base
  def signup_notification(user)
    set_up_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = activate_url(:activation_code => user.activation_code)
  end
  
  def activation(user)
    set_up_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = root_url
  end
  
  def password_reset(user)
    set_up_email(user)
    @subject += 'Password reset'
    @body[:url] = password_reset_url(:activation_code => user.activation_code)
  end
  
  def password_change_notification(user)
    set_up_email(user)
    @subject += 'Your password was changed'
    @body[:url] = home_url('contact')
  end
  
  def email_change_notification(user, old_email)
    set_up_email(user)
    @recipients  = old_email
    @subject += 'Your email was changed'
    @body[:url] = home_url('contact')
  end
  
  def comment_notification(user, comment)
    set_up_email(user)
    @subject += 'Your idea has received a comment'
    @body[:comment] = comment
    @body[:url] = idea_url(comment.idea)
  end
  
  def life_cycle_notification(user, life_cycle_step)
    set_up_email(user)
    @subject += "New idea requiring attention in #{life_cycle_step.name}"
    @body[:life_cycle_step] = life_cycle_step
    @body[:url] = admin_root_url
  end
  
  protected
    def set_up_email(user)
      @recipients  = "#{user.email}"
      @from        = SHORT_SITE_NAME
      @subject     = "[#{SHORT_SITE_NAME.upcase}] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
