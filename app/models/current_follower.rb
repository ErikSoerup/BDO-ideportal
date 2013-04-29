# == Schema Information
#
# Table name: current_followers
#
#  id         :integer          not null, primary key
#  current_id :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class CurrentFollower < ActiveRecord::Base
  belongs_to :current
  belongs_to :user
end
