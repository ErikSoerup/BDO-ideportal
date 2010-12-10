class AddRecentContributionPoints < ActiveRecord::Migration
  def self.up
    add_column :users, :recent_contribution_points, :float
    
    puts 'Updating user contribution points...'
    
    Idea.reset_column_information
    User.reset_column_information
    Vote.reset_column_information
    Comment.reset_column_information
    
    User.transaction do
      total_count = User.count
      done_count = 0
      User.find(:all).each do |user|
        user.recent_contribution_points = user.contribution_points
        user.recalculate_contribution_points
        user.save(false)
        done_count += 1
        print "\015#{done_count} / #{total_count} (#{done_count * 100 / total_count}%)"
        STDOUT.flush
      end
    end
    puts ' Done.'
  end

  def self.down
    remove_column :users, :recent_contribution_points
  end
end
