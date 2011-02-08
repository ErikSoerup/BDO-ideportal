class AddSubscribers < ActiveRecord::Migration
  def self.up
    create_table :ideas_subscribers, :force => true, :id => false do |t|
      t.integer :idea_id
      t.integer :user_id
    end
    create_table :currents_subscribers, :force => true, :id => false do |t|
      t.integer :current_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :ideas_subscribers
    drop_table :currents_subscribers
  end
end
