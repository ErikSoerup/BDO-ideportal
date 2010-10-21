class AddIdeaCurrentRelationship < ActiveRecord::Migration
  def self.up
    default_current = Current.new(
      :title => 'Default Current',
      :description => 'Default current')
    default_current.id = Current::DEFAULT_CURRENT_ID
    default_current.save!
    add_column :ideas, :current_id, :integer, :default=>Current::DEFAULT_CURRENT_ID
  end

  def self.down
    remove_column :ideas, :current_id
  end
end
