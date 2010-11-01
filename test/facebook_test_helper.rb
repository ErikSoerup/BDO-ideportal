require 'mocha'

module FacebookTestHelper
  
  def mock_facebook_user(fb_uid)
    mock_user    = fb_uid ? stub(:id => fb_uid) : nil
    mock_client  = fb_uid ? stub(:access_token => 'fb_at') : nil
    mock_profile = fb_uid ? stub(:name => 'Bill', :email => 'dongle@frux.com') : nil
    
    @controller.expects(:current_facebook_user).at_least(0).returns(mock_user)
    @controller.expects(:current_facebook_client).at_least(0).returns(mock_client)
    Mogli::User.expects(:find).at_least(0).with("me", mock_client).returns(mock_profile)
  end
  
end

