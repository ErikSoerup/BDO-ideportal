# == Schema Information
#
# Table name: comments
#
#  id                    :integer          not null, primary key
#  idea_id               :integer
#  author_id             :integer
#  text                  :text
#  created_at            :datetime
#  updated_at            :datetime
#  inappropriate_flags   :integer          default(0)
#  hidden                :boolean          default(FALSE)
#  ip                    :string(64)
#  user_agent            :string(255)
#  marked_spam           :boolean          default(FALSE)
#  spam_checked          :boolean          default(FALSE), not null
#  notifications_sent    :boolean          default(FALSE), not null
#  document_file_name    :string(255)
#  document_content_type :string(255)
#  document_file_size    :integer
#  document_updated_at   :datetime
#  vectors               :text
#

class Comment < ActiveRecord::Base
  include SpamFiltering

  acts_as_authorizable

  #  has_attached_file :document,
  #    :storage => :s3,
  #    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
  #    :path => ":attachment/comment/:id/:style.:extension"
  has_many    :comment_documents
  belongs_to  :idea
  belongs_to  :author, :class_name => 'User'

  def comment_type
    'comment'
  end

  validates_presence_of :idea, :author, :text
  validate :idea_not_closed

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
  end

  def after_save
    notify_subscribers!
  end

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
