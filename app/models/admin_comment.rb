# == Schema Information
#
# Table name: admin_comments
#
#  id         :integer          not null, primary key
#  idea_id    :integer
#  author_id  :integer
#  text       :text
#  created_at :datetime
#  updated_at :datetime
#

class AdminComment < ActiveRecord::Base
  
  belongs_to :idea
  belongs_to :author, :class_name => 'User'
  
  validates_presence_of :idea, :author, :text
  
end
