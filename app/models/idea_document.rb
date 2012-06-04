class IdeaDocument < ActiveRecord::Base
  belongs_to :idea
  
  has_attached_file :document,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => ":attachment/idea/:id/:style.:extension"
end
