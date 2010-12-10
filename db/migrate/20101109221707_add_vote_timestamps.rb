class AddVoteTimestamps < ActiveRecord::Migration
  def self.up
    add_column :votes, :created_at, :timestamp
    add_column :votes, :updated_at, :timestamp
  end

  def self.down
    remove_column :votes, :updated_at
    remove_column :votes, :created_at
  end
end
