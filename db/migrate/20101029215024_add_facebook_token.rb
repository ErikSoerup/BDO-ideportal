class AddFacebookToken < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_access_token, :string
    add_column :users, :facebook_post_ideas, :boolean
  end

  def self.down
    remove_column :users, :facebook_post_ideas
    remove_column :users, :column_name
  end
end
