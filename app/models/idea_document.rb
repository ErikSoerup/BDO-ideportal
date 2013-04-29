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

class IdeaDocument < ActiveRecord::Base
  belongs_to :idea
  has_attached_file :document,
                    :storage        => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :path           => ":attachment/idea/:id/:style.:extension"
end
