class AddAttachmentIdToIdea < ActiveRecord::Migration
  def self.up
    add_column :attachments, :idea_id, :integer
  end

  def self.down
    remove_column :attachments, :idea_id
  end
end
