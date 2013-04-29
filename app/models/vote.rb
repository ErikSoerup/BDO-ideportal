# == Schema Information
#
# Table name: votes
#
#  id         :integer          not null, primary key
#  idea_id    :integer
#  user_id    :integer
#  counted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class Vote < ActiveRecord::Base

  belongs_to :idea
  belongs_to :user

  # validations
  validates_uniqueness_of :user_id, :scope => :idea_id, :message => 'Cannot create duplicate votes for same user/idea combination.'
  validate :idea_not_closed

  def idea_not_closed
    if !idea.nil? && idea.closed?
      errors.add_to_base("You are trying to vote on an idea within a closed current.  That's not allowed.")
    end
  end

  def count!
    transaction do
      lock!
      return if counted
      idea.lock!
      idea.rating += 1
      idea.save!
      self.counted = true
      save!
    end
  end

end
