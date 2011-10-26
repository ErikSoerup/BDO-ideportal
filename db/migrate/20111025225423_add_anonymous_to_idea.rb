class AddAnonymousToIdea < ActiveRecord::Migration
  def self.up
    add_column :ideas, :is_anonymous, :boolean
  end

  def self.down
    remove_column :ideas, :is_anonymous
  end
end
