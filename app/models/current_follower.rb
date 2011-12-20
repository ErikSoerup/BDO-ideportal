class CurrentFollower < ActiveRecord::Base
  belongs_to :current
  belongs_to :user
end
