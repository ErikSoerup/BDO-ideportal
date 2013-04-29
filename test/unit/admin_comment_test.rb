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

require File.dirname(__FILE__) + '/../test_helper'

class AdminCommentTest < ActiveSupport::TestCase
  scenario :basic
  
  def test_text_required
    test_field_error AdminComment, :text, nil, {}
    test_field_error AdminComment, :text, '', {}
  end
  
  def test_author_required
    test_field_error AdminComment, :author, nil, {}
  end
  
  def test_idea_required
    test_field_error AdminComment, :idea, nil, {}
  end
end
