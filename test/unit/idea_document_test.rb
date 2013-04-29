# == Schema Information
#
# Table name: idea_documents
#
#  id                    :integer          not null, primary key
#  document_file_name    :string(255)
#  document_content_type :string(255)
#  document_file_size    :integer
#  document_updated_at   :datetime
#  idea_id               :integer
#  created_at            :datetime
#  updated_at            :datetime
#

require 'test_helper'

class IdeaDocumentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
