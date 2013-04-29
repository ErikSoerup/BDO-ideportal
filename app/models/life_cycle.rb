# == Schema Information
#
# Table name: life_cycles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class LifeCycle < ActiveRecord::Base
  acts_as_authorizable

  has_many :steps, :class_name => 'LifeCycleStep', :order => 'position', :dependent => :destroy
  validates_presence_of :name
end
