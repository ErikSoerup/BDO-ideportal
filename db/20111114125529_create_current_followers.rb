class CreateCurrentFollowers < ActiveRecord::Migration
  def self.up
    create_table :current_followers do |t|
      t.integer :current_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :current_followers
  end
end
