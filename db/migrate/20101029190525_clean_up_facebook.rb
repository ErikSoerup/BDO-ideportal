class CleanUpFacebook < ActiveRecord::Migration
  def self.up
    drop_table :facebook_templates
    remove_column :users, :fb_email_hash
    rename_column :users, :fb_uid, :facebook_uid
  end

  def self.down
    rename_column :users, :facebook_uid, :fb_uid
    create_table :facebook_templates, :force => true do |t|
      t.string :template_name, :null => false
      t.string :content_hash, :null => false
      t.string :bundle_id, :null => true
    end
    add_index :facebook_templates, :template_name, :unique => true
    add_column :users, :fb_email_hash, :string
  end
end
