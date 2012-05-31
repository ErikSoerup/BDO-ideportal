class CreateIdeaDocuments < ActiveRecord::Migration
  def self.up
    create_table :idea_documents do |t|
      t.string   :document_file_name
      t.string   :document_content_type
      t.integer  :document_file_size
      t.datetime :document_updated_at
      t.integer  :idea_id
      t.timestamps
    end
  end

  def self.down
    drop_table :idea_documents
  end
end
