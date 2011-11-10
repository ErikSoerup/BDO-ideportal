class IdeaObserver < ActiveRecord::Observer

  def after_save(idea)
    if idea.life_cycle_step_id_changed? && idea.life_cycle_step
      idea.life_cycle_step.admins.each do |admin|
        next unless admin.notify_on_state?
        UserMailer.deliver_life_cycle_notification(admin, idea.life_cycle_step)
      end
    end

    if idea.inventor.followers.present?
      puts "Call back called properly"
      idea.inventor.followers.each do |follower|
        Delayed::Job.enqueue IdeaPostedFollowerJob.new(follower,idea)
      end
    end
  end

end
