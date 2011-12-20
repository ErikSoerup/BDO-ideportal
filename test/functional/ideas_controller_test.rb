require File.dirname(__FILE__) + '/../test_helper'
require 'ideas_controller'
require 'twitter_test_helper'
require 'facebook_test_helper'
require 'mocha'

class IdeasControllerTest < ActionController::TestCase
  scenario :basic
  
  include TwitterTestHelper
  include FacebookTestHelper

  def setup
    @controller = IdeasController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @expected_job_count = 0
  end
  
  def teardown
    job_count = Delayed::Job.count
    Delayed::Job.delete_all
    assert_equal @expected_job_count, job_count
  end

  def test_index
    get :index
    assert_response :success
    assert_equal_unordered [@barbershop_discount, @walruses_in_stores, @tranquilizer_guns, @give_up_all_hope], @controller.current_objects
    
    assert_tag    :content => @walruses_in_stores.title
    assert_tag    :content => @barbershop_discount.title
    assert_no_tag :content => @hidden_idea.title
    assert_no_tag :content => @orphan_idea.title
    assert_no_tag :content => @inactive_user_idea.title
  end
  
  def test_index_no_spam
    get :index
    assert_response :success
    assert_equal_unordered [@barbershop_discount, @walruses_in_stores, @tranquilizer_guns, @give_up_all_hope], @controller.current_objects
    
    assert_no_tag :content => @spam_idea.title
  end
  
  def test_search_recent
    get :index, :search => 'recent'
    assert_response :success
    assert_equal_unordered [@barbershop_discount, @walruses_in_stores, @tranquilizer_guns, @give_up_all_hope], @controller.current_objects
  end
  
  def test_search_blank
    get :index, :search_text => ''
    assert_response :success
  end
  
  def test_search_hot
    @walruses_in_stores.add_vote!(@quentin)
    @tranquilizer_guns.rating = 100
    @tranquilizer_guns.save!
    get :index, :search => 'hot'
    assert_response :success
    assert_equal_unordered [@tranquilizer_guns, @walruses_in_stores, @barbershop_discount, @give_up_all_hope], @controller.current_objects
  end
  
  def test_search_top_voted
    @walruses_in_stores.add_vote!(@quentin)
    @tranquilizer_guns.rating = 100
    @tranquilizer_guns.save!
    get :index, :search => 'top-voted'
    assert_response :success
    assert_equal_unordered [@walruses_in_stores, @barbershop_discount, @tranquilizer_guns, @give_up_all_hope], @controller.current_objects
  end
  
  def test_new
    assert_login_required @quentin, 'You must log in to create new ideas.' do
      get :new
    end
    assert_tag :tag => 'input', :attributes => { :type => "hidden", :name=>"idea[current_id]"  }
    assert_response :success
  end
  
  def test_create_idea_logged_in
    old_ideas = Idea.find(:all)
    login_as @quentin
    post :create,
      :idea => { :title => 'foo', :description => 'bar', :tag_names => 'one two, three' },
      :tags => { -2 => 'five six', 3 => 'seven, three, eight' }  # javascript tags
    assert_redirected_to idea_path(assigns(:idea))
    
    new_ideas = Idea.find(:all) - old_ideas
    assert_equal 1, new_ideas.size
    new_idea = new_ideas.first
    
    assert_equal 'foo', new_idea.title
    assert_equal 'bar', new_idea.description
    assert_equal 'eight, five six, one two, seven, three', new_idea.tag_names
    assert_equal @quentin, new_idea.inventor
    @expected_job_count = 1 # spam filtering
  end
  
  def test_create_idea_not_logged_in
    old_ideas = Idea.find(:all)
    post :create, :idea => { :title => 'foo', :description => 'bar' }
      
    # Login required...
    assert_redirected_to login_path
    assert_equal 'You must log in to create new ideas.', flash[:info]
    
    # ...but orphan idea still created!
    new_ideas = Idea.find(:all) - old_ideas
    assert_equal 1, new_ideas.size
    new_idea = new_ideas.first
    
    assert_equal 'foo', new_idea.title
    assert_equal 'bar', new_idea.description
    assert_equal nil, new_idea.inventor
    
    assert_equal assign_idea_path(new_idea), session[:return_to]
    assert_equal 'post', session[:return_to_method]
    @expected_job_count = 1 # spam filtering
  end
  
  def tweet_idea(title, opts = {})
    old_ideas = Idea.find(:all)
    
    # Ensure tweet is asynchronous
    expect_no_twitter_auth_verification

    login_as @tweeter
    post :create, :idea => { :title => title, :description => 'bar' }
    
    # Ensure create succeeded
    assert_redirected_to idea_path(assigns(:idea))
    
    new_ideas = Idea.find(:all) - old_ideas
    assert_equal 1, new_ideas.size
    new_idea = new_ideas.first
    
    assert_equal title, new_idea.title
    assert_equal @tweeter, new_idea.inventor
    
    # Now send tweet
    
    tweet_content = nil
    if opts[:twitter_exception]
      expect_tweet_and_raise_exception
    else
      expect_tweet { |msg| tweet_content = msg }
    end
    
    Delayed::Worker.new(:quiet => true).work_off
    
    [new_idea, tweet_content]
  end
  
  def test_create_idea_and_tweet
    new_idea, tweet_content = tweet_idea('foo')
    assert_equal tweet_content, "Idea for #{COMPANY_NAME}: foo #{idea_url(new_idea, :title_in_url => false)}"
  end
  
  def test_long_idea_title_truncated_in_tweet
    long_title = '0123456789' * 12
    new_idea, tweet_content = tweet_idea(long_title)
    
    content_pattern = /^Idea for #{COMPANY_NAME}: (\d+)... #{idea_url(new_idea, :title_in_url => false)}$/
    assert_match content_pattern, tweet_content
    tweet_content =~ content_pattern
    assert_match /^#{$1}/, long_title
    assert_equal 140, tweet_content.length
  end
  
  def test_create_idea_and_twitter_error
    new_idea = tweet_idea('foo', :twitter_exception => true)
    
    assert_not_nil new_idea
    @expected_job_count = 1
  end
  
  def facebook_post_idea(title, opts = {})
    old_ideas = Idea.find(:all)
    
    # Ensure Facebook interaction is asynchronous
    expect_no_facebook_post
    mock_facebook_user @facebooker.facebook_uid

    login_as @facebooker
    post :create, :idea => { :title => title, :description => 'bar' }
    
    # Ensure create succeeded
    assert_redirected_to idea_path(assigns(:idea))
    
    new_ideas = Idea.find(:all) - old_ideas
    assert_equal 1, new_ideas.size
    new_idea = new_ideas.first
    
    assert_equal title, new_idea.title
    assert_equal @facebooker, new_idea.inventor
    
    # We should have picked up the new token in ApplicationController.update_facebook_access_token
    @facebooker.reload
    assert_equal 'mock_fb_access_token', @facebooker.facebook_access_token
    
    # Now post idea
    
    post_content = nil
    if opts[:facebook_exception]
      expect_facebook_post_and_raise_exception @facebooker
    else
      expect_facebook_post(@facebooker) { |opts| post_content = opts }
    end
    
    # Set :quiet => false if you suspect the job is failing!
    Delayed::Worker.new(:quiet => true).work_off
    
    [new_idea, post_content]
  end
  
  def test_create_idea_and_post_to_facebook
    new_idea, post_content = facebook_post_idea('foo')
    expected_content = {
     :description => "bar",
     :message => "Idea for #{COMPANY_NAME}: foo",
     :source => idea_url(new_idea),
     :name => "Vote it up on #{LONG_SITE_NAME}"
    }
    assert_equal expected_content, post_content
    assert_nil flash[:info]
  end

  def test_create_idea_and_facebook_error
    new_idea, post_content = facebook_post_idea('foo', :facebook_exception => true)
    
    assert_not_nil new_idea
    assert_nil flash[:info]
    @expected_job_count = 1
  end
  
  def facebook_post_deferred_idea
    expect_no_facebook_post

    login_as @facebooker
    post :create, :idea => { :title => 'foo', :description => 'bar' }
    
    fb_post_jobs = Delayed::Job.all.select { |job| job.payload_object.kind_of?(FacebookPostIdeaJob)  }
    assert_equal 1, fb_post_jobs.count
    job = fb_post_jobs.first
    assert_equal 0, job.attempts
    assert job.run_at > 10.seconds.from_now
    
    @expected_job_count = 2 # spam + fb post
  end
  
  def test_facebook_post_not_logged_in_to_facebook
    facebook_post_deferred_idea
    
    assert !(flash[:info] =~ /FB.logout/)
    assert flash[:info] =~ /facebook_login/
  end
  
  def test_facebook_post_logged_in_as_wrong_facebook_user
    mock_facebook_user @tweeter
    facebook_post_deferred_idea
    
    # This match will have to change if we ever find a single popup-blocker-friendly call that lets
    # the user log in as a different user on FB:
    assert flash[:info] =~ /FB.logout/
    assert flash[:info] =~ /facebook_login/
  end
  
  def test_cannot_set_prohibited_fields
    login_as @sally
    old_ideas = Idea.find(:all)
    fake_time = Time.utc(2007, 10, 10)
    post :create, :idea => {
      :title => 'foo',
      :description => 'bar',
      :rating => 100,
      :inventor_id => @quentin.id,
      :created_at => fake_time,
      :updated_at => fake_time,
      :flagged => true,
      :viewed => true,   
      :inappropriate_flags => 10,
      :hidden => true,
      :decayed_at => fake_time
    }
    new_idea = (Idea.find(:all) - old_ideas).first
    assert_not_nil new_idea
    
    assert_not_equal new_idea.rating, 100
    assert_not_equal new_idea.inventor_id, @quentin.id
    assert_not_equal new_idea.created_at, fake_time
    assert_not_equal new_idea.updated_at, fake_time
    assert_not_equal new_idea.flagged, true
    assert_not_equal new_idea.viewed, true
    assert_not_equal new_idea.inappropriate_flags, 10
    assert_not_equal new_idea.hidden, true
    assert_not_equal new_idea.decayed_at, fake_time
    @expected_job_count = 1 # spam filtering
  end
  
  def test_create_idea_duplicate_tags
    old_ideas = Idea.find(:all)
    login_as @quentin
    post :create,
      :idea => { :title => 'foo', :description => 'bar', :tag_names => 'three, one two, three, three, three' },
      :tags => { -2 => 'five six', 3 => 'seven, three, eight, three' }  # javascript tags
    assert_redirected_to idea_path(assigns(:idea))
    
    new_ideas = Idea.find(:all) - old_ideas
    assert_equal 1, new_ideas.size
    new_idea = new_ideas.first
    
    assert_equal 'eight, five six, one two, seven, three', new_idea.tag_names
    assert_equal @quentin, new_idea.inventor
    @expected_job_count = 1 # spam filtering
  end
  
  def test_assign_idea_owner
    assert_equal nil, @orphan_idea.inventor
    login_as @quentin
    post :assign, :id => @orphan_idea.id
    @orphan_idea.reload
    assert_equal @quentin, @orphan_idea.inventor
    assert_redirected_to idea_path(@orphan_idea)
  end
  
  def test_cannot_reassign_idea_owner
    login_as @quentin
    post :assign, :id => @barbershop_discount.id
    @barbershop_discount.reload
    assert_equal @sally, @barbershop_discount.inventor
  end

  def test_show_idea
    get :show, :id => @walruses_in_stores.id
    assert_response :success
    assert_tag :content => @walruses_in_stores.title
    assert_tag :content => @walruses_in_stores.description
    assert_tag :tag => 'a', :content => @walrus_tag.name,
      :attributes => { :href => idea_search_path(:search => ['tag', @walrus_tag.name]) }
    assert_no_tag :content => @walrus_comment1.text   # inactive user
    assert_tag    :content => @walrus_comment2.text
    assert_no_tag :content => @hidden_comment.text
    assert_no_tag :content => @hidden_idea.title
    assert_no_tag :content => @orphan_idea.title
    assert_no_tag :content => @inactive_user_idea.title
  end
  
  def test_show_indicates_duplicates
    get :show, :id => @walruses_in_stores.id
    
    assert_response :success
    assert_tag :attributes => { :class => 'entry-duplicates' },
      :descendant => { :tag => 'a', :content => @duplicate_idea.title, :attributes => { :href => idea_path(@duplicate_idea) }}
    assert_tag :attributes => { :class => 'vote' }
  end
  
  def test_show_indicates_duplicate_of
    get :show, :id => @duplicate_idea.id
    
    assert_response :success
    assert_tag :attributes => { :class => 'info' },
      :descendant => { :tag => 'a', :content => @walruses_in_stores.title, :attributes => { :href => idea_path(@walruses_in_stores) }}
    assert_no_tag :attributes => { :class => /.*vote.*/ }
  end
  
  def test_update_idea_requires_ownership
    login_as @aaron
    assert_raises(RuntimeError) do
      put :update, :id => @walruses_in_stores.id, :idea => { :title => 'oof', :description => 'rab' }
    end
    @walruses_in_stores.reload
    assert_not_equal 'oof', @walruses_in_stores.title
    assert_not_equal 'rab', @walruses_in_stores.description
  end
  
  def test_update_idea
    login_as @quentin
    put :update, :id => @walruses_in_stores.id, :idea => { :title => 'oof', :description => 'rab' }
    assert_redirected_to idea_path(assigns(:idea))
    
    @walruses_in_stores.reload
    assert_equal 'oof', @walruses_in_stores.title
    assert_equal 'rab', @walruses_in_stores.description
  end
  
  def test_orphan_idea_not_shown
    get :show, :id => @orphan_idea.id
    assert_response 410
  end
  
  def test_hidden_idea_not_shown
    get :show, :id => @hidden_idea.id
    assert_response 410
  end
  
  def test_inactive_user_idea_not_shown
    get :show, :id => @inactive_user_idea.id
    assert_response 410
  end
  
  def test_inactive_user_can_see_own_idea
    login_as @inactive_user_idea.inventor
    get :show, :id => @inactive_user_idea.id
    assert_response :success
    assert_tag :content => @inactive_user_idea.title
    # We seem to have got rid of this message:
    # assert_tag :content => /Your idea will not be publicly visible until you confirm your account/i
  end
  
  def test_subscribe
    login_as @quentin
    put :subscribe, :id => @walruses_in_stores.id
    assert_redirected_to :action => :show
    @walruses_in_stores.reload
    assert_equal_unordered [@aaron, @quentin], @walruses_in_stores.subscribers
  end
  
  def test_unsubscribe
    login_as @aaron
    get :unsubscribe, :id => @barbershop_discount.id
    assert_redirected_to :action => :show
    assert flash[:info] =~ /no longer subscribed/
    @walruses_in_stores.reload
    assert_equal_unordered [@quentin], @barbershop_discount.subscribers
  end
  
  def test_unsubscribe_user_with_comment_notification
    login_as @sally
    get :unsubscribe, :id => @barbershop_discount.id
    
    assert_redirected_to :controller => :users, :action => :edit
    assert flash[:info] =~ /uncheck/
    assert !(flash[:info] =~ /no longer subscribed/)
    
    @walruses_in_stores.reload
    assert_equal_unordered [@quentin, @aaron], @barbershop_discount.subscribers
  end
  
end
