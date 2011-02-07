# Customize with your project's name. Example:
#
#     COMPANY_NAME = 'Widgets by Quentin'
#     SHORT_SITE_NAME = 'Ideaomatic'

COMPANY_NAME = 'YOUR_COMPANY_NAME'
SHORT_SITE_NAME = 'BBYIDX'
LONG_SITE_NAME = "#{COMPANY_NAME} #{SHORT_SITE_NAME}"

# Set these to the hostnames of the machines where you'll be doing your deploys.
PRODUCTION_HOST = 'bbyidx.com'
STAGING_HOST = 'bbyidx.com'

# Specify a long random string for SESSION_SECRET to secure user sessions
SESSION_SECRET = nil
SESSION_KEY = "_#{SHORT_SITE_NAME.downcase}_session"

# Configure Twitter in twitter.yml, then set "TWITTER_ENABLED = true" to enable Twitter integration.
# You can also set TWITTER_API_KEY and TWITTER_API_SECRET as environment variables.
TWITTER_ENABLED = ENV['TWITTER_API_KEY'] || ENV['RAILS_ENV'] == 'test'

# Configure Facebook in facebooker.yml, then set "FACEBOOK_ENABLED = true" to enable Twitter integration.
# You can also set FACEBOOK_APP_ID, FACEBOOK_API_KEY and FACEBOOK_APP_SECRET as environment variables.
FACEBOOK_ENABLED = ENV['FACEBOOK_API_KEY'] || ENV['RAILS_ENV'] == 'test'

# Customize the user contribution points for various activities, if you like.
CONTRIBUTION_SCORES = {
  :idea    => 10,
  :comment => 2,
  :vote    => 1
}

# Get an ID from http://addthis.com to add a "Share This" link to ideas.
ADDTHIS_ID = nil

# Get a tracking code from http://www.google.com/analytics/ to enable Google Analytics.
GOOGLE_ANALYTICS_TRACKING_CODE = nil

# Get a key from http://www.google.com/webmasters/ to enable Google's webmaster tools.
GOOGLE_WEBMASTER_KEY = nil

# Akistmet provides spam filtering for comments. Get a key at: http://akismet.com/commercial/ or http://akismet.com/personal/
# Once you've registered, pass your Akismet API key in the environment variable RAKISMET_KEY.
# This will enable spam filtering.
RAKISMET_URL = "http://#{PRODUCTION_HOST}"
SPAM_PURGE_AGE = 30 # days; set to nil to disable spam purging

# This is used for two purposes:
#  (1) The db:seed rake task uses this as the zip code for the initial admin user (which can be changed).
#  (2) When displaying nearby ideas, if browser geolocation fails and the user is not logged in,
#      and we thus have no idea where the user is located, the system displays ideas near this zip code.
DEFAULT_ZIP_CODE = '55423'
