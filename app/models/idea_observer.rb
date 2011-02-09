class IdeaObserver < ActiveRecord::Observer
  
  def after_create(idea)
    if idea.current
      idea.current.subscribers.each do |subscriber|
        Delayed::Job.enqueue IdeaInCurrentNotificationJob.new(subscriber, idea)
      end
    end
  end
  
  def after_save(idea)
    if idea.life_cycle_step_id_changed? && idea.life_cycle_step
      idea.life_cycle_step.admins.each do |admin|
        next unless admin.notify_on_state?
        UserMailer.deliver_life_cycle_notification(admin, idea.life_cycle_step)
      end
    end
  end
  
end
