namespace :ideax do
  desc 'Bulk update all time-base decay fields in DB'
  task :decay => :environment do
    Decayer.run_all(
      :half_life => {
        :idea_rating => 20.days,
        :user_recent_contribution_points => 60.days
      }
    )
  end
end

