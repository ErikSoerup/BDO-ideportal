class AddIdeaIpAndUserAgent < ActiveRecord::Migration
  def self.up
    add_column :ideas, :ip, :string, :limit => 16
    add_column :ideas, :user_agent, :string
  end

  def self.down
    remove_column :ideas, :ip
    remove_column :ideas, :user_agent
  end
end
