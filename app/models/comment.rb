class Comment < ActiveRecord::Base
  acts_as_authorizable

<<<<<<< HEAD
  has_attached_file :document,
      :storage => :s3,
      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
      :path => ":attachment/comment/:id/:style.:extension"

=======
#  has_attached_file :document,
#    :storage => :s3,
#    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
#    :path => ":attachment/comment/:id/:style.:extension"
  has_many :comment_documents
>>>>>>> 700984efbc1a57881f6ccdddaf3ff76d4c3a703d
  belongs_to :idea
  belongs_to :author, :class_name => 'User'
  def comment_type
    'comment'
  end

  validates_presence_of :idea, :author, :text
  validate :idea_not_closed

  include SpamFiltering

  def spam_filtering_user
    author
  end

  def spam_filtering_text
    text
  end

  def idea_not_closed
    if !idea.nil? && idea.closed?
      errors.add_to_base("You are trying to comment on an idea within a closed current.  That's not allowed.")
    end
  end

  include InappropriateFlag
  unless !Comment.table_exists?
    acts_as_tsearch :fields=>%w(text)
  end

  def after_create
    author.record_contribution! :comment
    send_later :check_spam!  # also notifies subscribers
<<<<<<< HEAD
    send_later :notify_subscribers!
  end

=======
  end

  def after_save
    notify_subscribers!
  end
>>>>>>> 700984efbc1a57881f6ccdddaf3ff76d4c3a703d

  def editing_expired?
    created_at < 15.minutes.ago
  end

  def editable_by?(user)
    user == author && !editing_expired?
  end

  def visible?
    !hidden && author.active?
  end

  def should_notify_subscribers?
    spam_checked? && visible? && idea.visible?
  end

  def notify_subscribers!
<<<<<<< HEAD

=======
>>>>>>> 700984efbc1a57881f6ccdddaf3ff76d4c3a703d
    if !notifications_sent? && should_notify_subscribers?
      subscribers = idea.subscribers.dup
      inventor = idea.inventor
      subscribers << inventor if inventor && inventor.notify_on_comments?
      subscribers.delete author
      subscribers.uniq!

      subscribers.each do |subscriber|
        Delayed::Job.enqueue CommentNotificationJob.new(subscriber, self)
      end

      self.notifications_sent = true
      self.save!
    end
  end

end
