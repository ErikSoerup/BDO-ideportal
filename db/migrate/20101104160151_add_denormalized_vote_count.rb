class AddDenormalizedVoteCount < ActiveRecord::Migration
  def self.up
    add_column :ideas, :vote_count, :integer
    
    puts 'Updating idea vote counts...'
    
    Idea.reset_column_information
    User.reset_column_information
    Vote.reset_column_information
    
    total_count = Idea.count
    done_count = 0
    Idea.find(:all).each do |idea|
      idea.update_vote_count
      idea.save!
      done_count += 1
      print "\015#{done_count} / #{total_count} (#{done_count * 100 / total_count}%)"
      STDOUT.flush
    end
    puts ' Done.'
  end

  def self.down
    remove_column :ideas, :vote_count
  end
end
