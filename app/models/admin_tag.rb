# == Schema Information
#
# Table name: admin_tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class AdminTag < ActiveRecord::Base
  include TagHelper

  has_and_belongs_to_many :ideas, :join_table => :ideas_admin_tags
end
