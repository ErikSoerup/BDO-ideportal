ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
        :address => 'smtp.gmail.com',
        :port => 587,
        :authentication => :plain,
        :user_name => 'noreply@centic.dk',
        :password => 'E87038'
}

ActionMailer::Base.raise_delivery_errors = true