class AddDenormalizedVoteCount < ActiveRecord::Migration
  def self.up
    add_column :ideas, :vote_count, :integer
    
    print 'Updating idea vote counts...'
    Idea.reset_column_information
    Idea.find(:all).each do |idea|
      idea.update_vote_count
      idea.save!
      print '.'
    end
    puts 'Done.'
  end

  def self.down
    remove_column :ideas, :vote_count
  end
end
