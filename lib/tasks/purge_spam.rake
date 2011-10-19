namespace :ideax do
  desc 'Remove old spam'
  task :purge_spam => :environment do
    SpamPurger.run_all
  end
end

