class CommentDocument < ActiveRecord::Base
  belongs_to :comment

  has_attached_file :document,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => ":attachment/comment/:id/:style.:extension"
end
