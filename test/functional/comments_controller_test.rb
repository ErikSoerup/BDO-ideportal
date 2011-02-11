require File.dirname(__FILE__) + '/../test_helper'
require 'comments_controller'

class CommentsControllerTest < ActionController::TestCase
  scenario :basic

  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @deliveries = ActionMailer::Base.deliveries = []
  end
  
  def test_index
    get :index
    assert_response :success
    assert_template 'comments/index'
    assert_no_tag :content => @walrus_comment1.text         # inactive user
    assert_tag :content => @walrus_comment2.text            # active user
    assert_no_tag :content => @hidden_comment.text          # comment hidden
    assert_no_tag :content => @comment_on_hidden_idea.text  # idea hidden
    assert_tag :tag => 'a', :attributes => { :href => idea_path(@walruses_in_stores) }
  end

  def test_new
    assert_login_required @quentin, 'You must log in to create new comments.' do
      get :new, :idea_id => @walruses_in_stores.id
    end
    assert_response :success
  end
  
  def test_create_comment
    old_count = Comment.count
    assert_login_required @quentin, 'You must log in to create new comments.' do
      post :create, :idea_id => @walruses_in_stores.id,
        :comment => { :text => 'foobar', :idea_id => @walruses_in_stores.id }
    end
    assert_equal old_count + 1, Comment.count
  
    assert_redirected_to idea_path(@walruses_in_stores)
  end
  
  def test_cannot_set_prohibited_fields
    login_as @sally
    old_comments = Comment.find(:all)
    fake_time = Time.utc(2007, 10, 10)
    post :create, :idea_id => @walruses_in_stores.id, :comment => {
      :text => 'foobar',
      :idea_id => @walruses_in_stores.id,
      :author_id => @quentin.id,
      :created_at => fake_time,
      :updated_at => fake_time,
      :inappropriate_flags => 100,
      :hidden => true
    }
    new_comment = (Comment.find(:all) - old_comments).first
    assert_not_nil new_comment
    
    assert_equal 'foobar', new_comment.text
    assert_equal @walruses_in_stores, new_comment.idea
    
    assert_not_equal new_comment.author_id, @quentin.id
    assert_not_equal new_comment.created_at, fake_time
    assert_not_equal new_comment.updated_at, fake_time
    assert_not_equal new_comment.inappropriate_flags, 10
    assert_not_equal new_comment.hidden, true
  end
  
  def test_update_comment
    assert_login_required @aaron, 'You must log in to edit comments.' do
      put :update, :id => @walrus_comment1.id,
        :comment => { :text => 'foobar' }
    end
    assert_equal  'foobar', @walrus_comment1.reload.text
    
    assert_equal @walruses_in_stores, assigns(:idea)
    
    assert_redirected_to idea_path(@walruses_in_stores)
  end
  
  def test_update_comment_non_owner
    assert_login_required @quentin, 'You must log in to edit comments.' do
      put :update, :id => @walrus_comment1.id,
        :comment => { :text => 'foobar' }
    end
    
    assert_not_equal  'foobar', @walrus_comment1.reload.text
  end
  
  def test_subscriber_notification
    new_comment = add_barbershop_comment
    assert_equal [], @deliveries   # should be delayed job
    assert_barbershop_subscribers_notified
    
    new_comment.notify_subscribers!
    assert_no_notifications_sent   # shouldn't allow double delivery
  end
  
  def test_no_notification_until_spam_checked
    Comment.any_instance.expects(:spam?).at_least(0).raises(Exception, 'akismet down')
    new_comment = add_barbershop_comment
    assert_no_notifications_sent
    
    Comment.any_instance.expects(:spam?).at_least(0).returns(false)
    assert_barbershop_subscribers_notified
  end
  
  def test_no_notification_if_spam
    Comment.any_instance.expects(:spam?).at_least(0).raises(Exception, 'akismet down')
    new_comment = add_barbershop_comment
    assert_no_notifications_sent
    
    Comment.any_instance.expects(:spam?).at_least(0).returns(true)
    assert_no_notifications_sent
    new_comment.reload
    assert new_comment.marked_spam
  end
  
  def test_no_notification_until_author_activated
    @quentin.state = 'pending'
    @quentin.save!
    
    new_comment = add_barbershop_comment
    assert_no_notifications_sent
    
    @quentin.activate!
    @deliveries.clear  # discard activation email
    assert_barbershop_subscribers_notified
  end

  def test_no_notification_for_hidden_idea
    @barbershop_discount.hidden = true
    @barbershop_discount.save!
    
    new_comment = add_barbershop_comment
    assert_no_notifications_sent
  end
  
private
  
  def add_barbershop_comment
    @barbershop_discount.comments.create!(
      :author => @quentin,
      :text => "I for one welcome our new barbershop overlords.",
      :ip => '1.2.3.4',
      :user_agent => 'Firefox or whatever')
  end
  
  def force_all_jobs
    Delayed::Job.find(:all).each do |job|
      job.run_at = nil
      job.attempts = 0
      job.save!
    end
    Delayed::Worker.new(:quiet => true).work_off
  end
  
  def assert_no_notifications_sent
    force_all_jobs
    assert_equal [], @deliveries.map { |d| "#{d.to}: #{d.subject}" }
  end
  
  def assert_barbershop_subscribers_notified
    force_all_jobs
    
    assert_email_sent @aaron, /ideas\/#{@barbershop_discount.id}/, /an idea/
    assert_email_sent @sally, /ideas\/#{@barbershop_discount.id}/, /your idea/
    # No email for Quentin, because he wrote the comment!
    assert_equal [], @deliveries.map { |d| "#{d.to}: #{d.subject}" }
    
    @barbershop_discount.reload
    assert_equal_unordered [@aaron, @quentin], @barbershop_discount.subscribers  # make sure we didn't modify subs
  end
  
end
