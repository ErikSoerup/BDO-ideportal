# == Schema Information
#
# Table name: comment_documents
#
#  id                    :integer          not null, primary key
#  document_file_name    :string(255)
#  document_content_type :string(255)
#  document_file_size    :integer
#  document_updated_at   :datetime
#  comment_id            :integer
#  created_at            :datetime
#  updated_at            :datetime
#

class CommentDocument < ActiveRecord::Base
  belongs_to :comment

  has_attached_file :document,
    :storage        => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path           => ":attachment/comment/:id/:style.:extension"
end
