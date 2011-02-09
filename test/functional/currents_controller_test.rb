require File.dirname(__FILE__) + '/../test_helper'
require 'ideas_controller'
require 'mocha'

class CurrentsControllerTest < ActionController::TestCase
  scenario :basic

  def setup
    @controller = CurrentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @deliveries = ActionMailer::Base.deliveries = []
  end

  def test_index
    get :index
    assert_response :success  
    # !! should not include @default_current! 
    assert !@controller.current_objects.include?(@default_current)
    [@walrus_attack_current, @orphan_current, @closed_current, @expired_current, @private_current].each {|c| @controller.current_objects.include?(c)}    
    assert_tag    :content => @walrus_attack_current.title
    assert_tag    :content => @walrus_attack_current.description
    assert_tag    :content => @orphan_current.title
    assert_tag    :content => @orphan_current.description    
  end

	# Individual current pages will have some basic stats such as the number of users, ideas, votes, and comments within that Current. 
	# All ideas within this current will be listed in the same format as the other idea pages. Current pages will also be socially sharable through the AddThis widget.  
  def test_show_current
    get :show, :id => @walrus_attack_current.id
    assert_response :success
    assert_tag :content => "Current: #{@walrus_attack_current.title}"
    assert_tag :content => @walrus_attack_current.description
    # ideas count should be 2
    #assert_tag :tag=>'li', :attributes =>{:class=>"ideas"}, :content=>"2"
    
    # Ideas belonging to the current should be listed
    [@tranquilizer_guns, @give_up_all_hope].each do |idea|
      assert_tag :content => idea.title
      assert_tag :content => idea.description
    end

    # Hidden ideas within the current should not show up
    assert @walrus_attack_current.ideas.include?(@hidden_idea)
    #puts assigns(:current_ideas).inspect
    assert !assigns(:current_ideas).include?(@hidden_idea)
    [@hidden_idea].each do |idea|
      assert_no_tag :content => idea.title
      assert_no_tag :content => idea.description
    end  
    
    # should show whether the current is invite_only
    assert_tag
    # should display list of invitees
    
  end
  
  def test_show_current_skips_orphans
    get :show, :id => @default_current.id
    assert_no_tag :content => @orphan_idea.title
  end
  
  def test_subscriber_notification
    new_idea = @walrus_attack_current.ideas.create!(
      :inventor => @quentin,
      :title => "Hunker down",
      :description => "...and hope.",
      :ip => '1.2.3.4',
      :user_agent => 'Firefox or whatever')
    assert_equal [], @deliveries
    
    Delayed::Worker.new(:quiet => true).work_off
    assert_email_sent @sally, /ideas\/#{new_idea.id}/
    assert_equal [], @deliveries
  end

  def test_subscriber_notification_delivered_when_user_activated
    new_idea = @walrus_attack_current.ideas.create!(
      :inventor => @aaron,
      :title => "Hunker down",
      :description => "...and hope.",
      :ip => '1.2.3.4',
      :user_agent => 'Firefox or whatever')
    Delayed::Worker.new(:quiet => true).work_off
    assert_equal [], @deliveries
    
    @aaron.activate!
    
    Delayed::Worker.new(:quiet => true).work_off
    assert_email_sent @sally, /ideas\/#{new_idea.id}/
  end
  
  def test_subscribe
    login_as @quentin
    put :subscribe, :id => @walrus_attack_current.id
    assert_redirected_to :action => :show
    @walrus_attack_current.reload
    assert_equal_unordered [@sally, @quentin], @walrus_attack_current.subscribers
  end
  
  def test_unsubscribe
    login_as @sally
    get :unsubscribe, :id => @walrus_attack_current.id
    assert_redirected_to :action => :show
    assert flash[:info] =~ /no longer subscribed/
    @walrus_attack_current.reload
    assert_equal [], @walrus_attack_current.subscribers
  end

end
