class AddNotificationSentFlag < ActiveRecord::Migration
  def self.up
    add_column :ideas,    :spam_checked, :boolean, :default => false, :null => false
    add_column :comments, :spam_checked, :boolean, :default => false, :null => false
    add_column :ideas,    :notifications_sent, :boolean, :default => false, :null => false
    add_column :comments, :notifications_sent, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :comments, :notifications_sent
    remove_column :ideas,    :notifications_sent
    remove_column :comments, :spam_checked
    remove_column :ideas,    :spam_checked
  end
end
