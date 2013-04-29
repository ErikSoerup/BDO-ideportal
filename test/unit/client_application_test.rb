# == Schema Information
#
# Table name: client_applications
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  url          :string(255)
#  support_url  :string(255)
#  callback_url :string(255)
#  key          :string(20)
#  secret       :string(40)
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#

require File.dirname(__FILE__) + '/../test_helper'
module OAuthHelpers
  
  def create_consumer
    @consumer=OAuth::Consumer.new(@application.key,@application.secret,
      {
        :site=>@application.oauth_server.base_url
      })
  end
  
end

class ClientApplicationTest < ActiveSupport::TestCase
  include OAuthHelpers
  scenario :oauth
  
  def setup
    @application = ClientApplication.create :name=>"Agree2",:url=>"http://agree2.com",:user=>@quentin
    create_consumer
  end

  def test_should_be_valid
    assert @application.valid?
  end
    
  def test_should_not_have_errors
    assert_equal [], @application.errors.full_messages
  end
  
  def test_should_have_key_and_secret
    assert_not_nil @application.key
    assert_not_nil @application.secret
  end

  def test_should_have_credentials
    assert_not_nil @application.credentials
    assert_equal @application.key, @application.credentials.key
    assert_equal @application.secret, @application.credentials.secret
  end
  
end
