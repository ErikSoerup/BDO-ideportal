class NotificationCurrentJob
  
  attr_accessor :user, :current

  def initialize(users,current)
    @user = users
     
    @current = current
    @current= Current.find(@current.id)
    UserMailer.deliver_notification_followers_ideas(@user, @current)
  end

  def perform
  end
  
end
