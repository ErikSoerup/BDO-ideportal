class Attachment < ActiveRecord::Base
  belongs_to :idea
  has_attached_file :document,
                :url => "/system/:attachment/:id/:style/:basename.:extension",
                :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension"

  #validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']
end
