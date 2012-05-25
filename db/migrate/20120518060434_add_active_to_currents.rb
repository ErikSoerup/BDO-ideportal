class AddActiveToCurrents < ActiveRecord::Migration
  def self.up
    add_column :currents, :active, :boolean, :default => true
  end

  def self.down
    remove_column :currents, :active
  end
end
