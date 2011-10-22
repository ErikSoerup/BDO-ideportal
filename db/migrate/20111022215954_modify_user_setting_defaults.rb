class ModifyUserSettingDefaults < ActiveRecord::Migration
  def self.up
    change_column :users, :notify_on_comments, :boolean, :default=>true
  end

  def self.down
    change_column :users, :notify_on_comments, :boolean, :default=>false
  end
end
