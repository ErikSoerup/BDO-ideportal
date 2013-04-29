# == Schema Information
#
# Table name: roles_users
#
#  user_id    :integer
#  role_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  id         :integer          primary key
#

# The table that links roles with users (generally named RoleUser.rb)
class RolesUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
end
