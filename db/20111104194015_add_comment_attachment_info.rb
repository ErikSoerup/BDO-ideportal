class AddCommentAttachmentInfo < ActiveRecord::Migration
  def self.up
  	add_column :comments, :document_file_name, :string
  	add_column :comments, :document_content_type, :string
  	add_column :comments, :document_file_size, :integer
  	add_column :comments, :document_updated_at, :datetime
  end

  def self.down
  	remove_column :comments, :document_file_name
  	remove_column :comments, :document_content_type
  	remove_column :comments, :document_file_size
  	remove_column :comments, :document_updated_at
  end
end
