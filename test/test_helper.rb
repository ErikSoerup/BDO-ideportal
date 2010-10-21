ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require "#{RAILS_ROOT}/vendor/gems/lazy-0.9.5/lazy"
gem 'thoughtbot-shoulda'
require 'shoulda'
require 'oauth/signature/plaintext'

# TODO: trigger scenarios builder every time

# Tsearch and rails tests don't play nicely together: when Rails tries to drop & repopulate
# the test DB, it messes tsearch up in several ways. Here we patch up the mess it makes, ignoring
# the failures that occur if the fixes have already been applied.
begin
  ActiveRecord::Base.connection.execute 'CREATE TEXT SEARCH CONFIGURATION public.default ( COPY = pg_catalog.english )'
rescue ActiveRecord::StatementInvalid=>x
end
[Idea, Comment, User].each { |model| model.create_vector } # drops & recreates vector column


class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = true

  def test_field_error(model, field, value, defaults)
    fields = defaults.merge(field => value)
    obj = model.create(fields)
    assert obj.errors.on(field), "Expected error when #{model}.#{field} = #{value.inspect}"
    assert !obj.valid?
  end
  
  def assert_login_required(user, expected_flash_info = nil)
    yield
    assert session[:return_to], 'Action should require login, but does not'
    assert_redirected_to login_url
    assert_equal expected_flash_info, flash[:info] if expected_flash_info
    login_as user
    yield
  end
  
  def assert_admin_required(expected_flash_info = nil, &action)
    assert_login_required @aaron, nil, &action                       # This leaves us logged in as aaron, and...
    assert_login_required @admin_user, expected_flash_info, &action  # ...that should fail this time around.
  end
  
  def assert_equal_unordered(expected, actual)
    missing = expected - actual
    unexpected = actual - expected
    unless missing.empty? && unexpected.empty?
      fail "Missing: #{missing.inspect}\nUnexpected: #{unexpected.inspect}"
    end
  end
  
  def get_xml(action, params = {})
    @request.env['HTTP_ACCEPT'] = 'application/xml'
    get action, params
    Nokogiri::XML(@response.body.to_s)
  end
  
  def post_xml(action, params = {})
    @request.env['HTTP_ACCEPT'] = 'application/xml'
    post action, params
    Nokogiri::XML(@response.body.to_s)
  end
  
  def oauth_params(user, app, params = {})
    req_token = app.create_request_token
    req_token.authorize!(user)
    req_token.provided_oauth_verifier = req_token.verifier
    acc_token = req_token.exchange!
    
    @@oauth_fake_nonce ||= 0
    params[:oauth_nonce] = (@@oauth_fake_nonce += 1)
    params[:oauth_timestamp] = Time.now.to_i
    params[:oauth_signature_method] = 'PLAINTEXT'
    params[:oauth_signature] = "#{app.secret}&#{acc_token.secret}"
    params[:oauth_consumer_key] = @phone_app.key
    params[:oauth_token] = acc_token.token
    params[:oauth_version] = "1.0a"
    
    params
  end
  
  def assert_xml_equal(xml, path, expected)
    assert_equal expected.to_s, xml.xpath(path).inner_html, "Looking for path #{path} in XML:\n#{xml}"
  end
  
  def match_xml_to_array(xml, path, array, &block)
    array = array.dup
    xml.xpath(path).each do |item_xml|
      yield item_xml, array.shift
    end
    assert_equal [], array, 'Items from expected array have no corresponding XML'
  end
  
  include AuthenticatedTestHelper
end

class ApplicationController
  def test_login_as(user)
    @current_user = user
  end
  
  def test_oauth_login_as(user)
    @current_user = user
    @skip_oauth = true
  end
  
  alias_method :oauth_required_without_test_hook, :oauth_required
  def oauth_required
    oauth_required_without_test_hook unless @skip_oauth
  end
  
  def rescue_action(e)
    raise e
  end
end

# Lazy load fixtures
if defined? LAZY_FIXTURE_PATCH_APPLIED  # prevent double application, which leads to infinite recursion
  raise 'Lazy fixture applied twice. It looks like test_helper was included twice. ' +
        'Are you perhaps requiring test_helper using a different path? Check the first line of your test file.'
else
  LAZY_FIXTURE_PATCH_APPLIED = true
  class Fixture
    alias_method :find_concrete, :find
  
    def find
      promise { find_concrete }
    end
  end
end
