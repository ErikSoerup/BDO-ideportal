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
    @subject += 'Nulstilling af kodeord til Ideportalen'
    @body[:user] = user
    @body[:url] = password_reset_url(:activation_code => user.activation_code)
  end

  
  def notification_followers_comments(user, idea)
    set_up_email(user)
    
    @subject = "Du følger nu ideen: \"#{strip_funkies(idea.title)}\""
    @body[:user] = user
    @body[:idea] = idea
    
  end
  
  def password_change_notification(user)
    set_up_email(user)
    @subject += 'Dit password til Ideportalen er ændret.'
    @body[:user] = user
    @body[:url] = home_url('contact')
  end

  def email_change_notification(user, old_email)
    set_up_email(user)
    @recipients  = old_email
    @subject += 'Din e-mail adresse er blevet ændret'
    @body[:user] = user
    @body[:url] = home_url('contact')
  end

  def notification_followers_ideas(user, current)
    set_up_email(user)
#    @body[:ideas] = ideas
    @subject ="Du følger nu hovedvejen: #{current.title}"
#    title=[]
#    description=[]
#    unless ideas.empty?
#      ideas.each do |i|
#        title << i.title
#      end
#    
#      ideas.each do |ii|
#        description << ii.description
#      end
#    end
#    
#    unless ideas.empty?
     @body[:current] = current
     
#      @body[:title] = title
#      @body[:desc] = description
#    end
  end
  
  def comment_notification(user, comment)
    set_up_email(user)
    @body[:comment] = comment
    @body[:user] = user
    @body[:url] = idea_url(comment.idea)
    @body[:unsubscribe_url] = unsubscribe_idea_url(comment.idea)
    @owner = (user == comment.idea.inventor)
    @subject = "#{@owner.name} har kommenteret din idé \"#{strip_funkies(comment.idea.title)}\""
  end

  def idea_in_current_notification(user, idea)
    set_up_email(user)
    @body[:user] = user
    @body[:idea] = idea
    @body[:url] = idea_url(idea)
    @body[:unsubscribe_url] = unsubscribe_current_url(idea.current)
    @subject += "#{idea.inventor.name} har tilføjet en ny ide til \"#{strip_funkies(idea.current.title)}\""
  end

  def idea_posted_to_followers(user,idea)
    set_up_email(user)
    emails = []
    unless user.followers.empty?
      user.followers.each do |u|
        emails << u.email.to_s + ","
      end
      @recipients=emails << user.email 
    else
      emails = user.email
      @recipients = emails.to_s 
    end
   
    
    @subject += "New idea by #{idea.inventor.name}"
    @body[:idea] = idea
    @body[:url] = idea_url(idea)
    @body[:unsubscribe_url] = unfollow_url(idea.inventor)
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
    @from        = EMAIL_FROM_ADDRESS
    @subject     = "[#{SHORT_SITE_NAME.upcase}] "
    @sent_on     = Time.now
    @body[:user] = user
  end

  def strip_funkies(s)
    s.gsub(/[<>&]/, '')
  end
end
