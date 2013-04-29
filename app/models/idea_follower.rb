# == Schema Information
#
# Table name: idea_followers
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  idea_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class IdeaFollower < ActiveRecord::Base
  belongs_to :idea
  belongs_to :user
end
