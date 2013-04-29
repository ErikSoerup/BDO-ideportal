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

require 'test_helper'

class CurrentFollowerTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
