# == Schema Information
#
# Table name: attachments
#
#  id                    :integer          not null, primary key
#  document_file_name    :string(255)
#  document_content_type :string(255)
#  document_file_size    :integer
#  document_updated_at   :datetime
#  idea_id               :integer
#

class Attachment < ActiveRecord::Base
  belongs_to :idea
  has_attached_file :document,
                    :url  => "/system/:attachment/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension"

  #validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']
end
