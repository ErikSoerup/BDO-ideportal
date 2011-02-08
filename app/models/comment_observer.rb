class CommentObserver < ActiveRecord::Observer
  
  def after_create(comment)
    subscribers = comment.idea.subscribers.dup
    inventor = comment.idea.inventor
    subscribers << inventor if inventor && inventor.notify_on_comments?
    subscribers.delete comment.author
    subscribers.uniq!
    
    subscribers.each do |subscriber|
      Delayed::Job.enqueue CommentNotificationJob.new(subscriber, comment)
    end
  end
  
end
