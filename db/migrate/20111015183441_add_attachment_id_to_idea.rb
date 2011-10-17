class AddAttachmentIdToIdea < ActiveRecord::Migration
  def self.up
    add_column :ideas, :attachment_id, :integer
  end

  def self.down
    remove_column :ideas, :attachment_id
  end
end
