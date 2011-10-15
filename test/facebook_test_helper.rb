require 'mocha'

module FacebookTestHelper
  
  def mock_facebook_user(fb_uid)
    mock_user    = fb_uid ? stub(:id => fb_uid) : nil
    mock_client  = fb_uid ? stub(:access_token => 'mock_fb_access_token') : nil
    mock_profile = fb_uid ? stub(:name => 'Bill', :email => 'dongle@frux.com') : nil
    
    @controller.expects(:current_facebook_user).at_least(0).returns(mock_user)
    @controller.expects(:current_facebook_client).at_least(0).returns(mock_client)
    Mogli::User.expects(:find).at_least(0).with("me", mock_client).returns(mock_profile)
  end
  
  def expect_no_facebook_post
    Mogli::Post.expects(:new).never
  end
  
  def expect_facebook_post(user, &block)
    mock_client = mock()
    mock_post = mock()
    mock_user = mock()
    mock_user.expects(:feed_create).with(mock_post).returns(nil)
    
    Mogli::Client.expects(:new).at_least_once.returns(mock_client)
    Mogli::User.expects(:new).at_least_once.with({:id => user.facebook_uid}, mock_client).returns(mock_user)
    Mogli::Post.expects(:new).once.with(&block).returns(mock_post)
  end
  
  def expect_facebook_post_and_raise_exception(user)
    mock_client = mock()
    mock_post = mock()
    mock_user = mock()
    mock_user.expects(:feed_create).with(mock_post).at_least_once.raises(Exception, 'facebook unavailable')
    
    Mogli::Client.expects(:new).at_least_once.returns(mock_client)
    Mogli::User.expects(:new).at_least_once.with({:id => user.facebook_uid}, mock_client).returns(mock_user)
    Mogli::Post.expects(:new).at_least_once.returns(mock_post)
  end
  
end

