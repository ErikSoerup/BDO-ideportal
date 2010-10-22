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

# Configure Twitter in twitter_config.yml, then set this to true to enable Twitter integration:
TWITTER_ENABLED = false

# Facebook support is experimental, and currently broken. We invite you to improve it!
# Settings in facebook.yml and facebooker.yml.
FACEBOOK_ENABLED = false

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
