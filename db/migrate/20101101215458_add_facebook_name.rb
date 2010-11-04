class AddFacebookName < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_name, :string
  end

  def self.down
    remove_column :users, :facebook_name
  end
end
