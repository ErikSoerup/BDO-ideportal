require File.dirname(__FILE__) + '/../test_helper'
require 'admin/currents_controller'

class Admin::CurrentsControllerTest < ActionController::TestCase
  scenario :basic
  
  def setup
    @controller = Admin::CurrentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_index
    assert_admin_required 'You must log in as an administrator to view currents in the admin interface.' do
      get :index
    end
    assert_response :success
    assert_template 'admin/currents/index'
    assert_tag :attributes => { :onclick => /#{edit_admin_current_path(@walrus_attack_current)}/ }
    assert_tag :content => @walrus_attack_current.title
    assert_tag :content => @walrus_attack_current.description
    assert_tag :content => @walrus_attack_current.description
    assert_tag :tag => 'a', :attributes => { :href => new_admin_current_path }
  end
  
  def test_new
    assert_login_required @admin_user, 'You must log in as an administrator to create new currents in the admin interface.' do
      get :new
    end
    assert_response :success
  end
  
  def test_create_current
    old_currents = Current.find(:all)
    assert_login_required @admin_user do
      post :create, :current => { :title => 'foo', :description => 'bar' }
    end
    assert_redirected_to edit_admin_current_path(assigns(:current))
    
    new_currents = Current.find(:all) - old_currents
    assert_equal 1, new_currents.size
    new_current = new_currents.first
    
    assert_equal 'foo', new_current.title
    assert_equal 'bar', new_current.description
    assert_equal @admin_user, new_current.inventor
  end
  
  def test_create_current_fails
    assert_no_difference 'Current.count' do
      assert_admin_required do
        post :create, :current => { :title => 'foo' }
      end
    end
    assert_response :success
  end
  
  def test_edit
    assert_admin_required do
      get :edit, :id => @walrus_attack_current.id
    end
    assert_response :success
    assert_template 'admin/currents/edit'
    assert_tag :tag => 'input', :attributes => { :value => @walrus_attack_current.title  }
    assert_tag :tag => 'textarea', :content => @walrus_attack_current.description
    assert_tag :tag => 'a',
      :attributes => { :href => new_idea_path("idea[current_id]"=>@walrus_attack_current.id) }
    assert_tag :tag => 'input', :attributes => { :name => "current[submission_deadline]" }
  end
  
  def test_update
    assert_admin_required do
      post :update, :id => @walrus_attack_current.id, :current => {
        :title => 'foo', :description => 'bar', :invitation_only => '1' }
    end
    assert_redirected_to edit_admin_current_path(@walrus_attack_current)
    
    @walrus_attack_current.reload
    assert_equal 'foo', @walrus_attack_current.title
    assert_equal 'bar', @walrus_attack_current.description
    assert_equal true, @walrus_attack_current.invitation_only
  end
  
  def test_update_fails
    old_desc = @walrus_attack_current.description
    assert_admin_required do
      post :update, :id => @walrus_attack_current.id, :current => {
        :title => 'foo', :description => nil, :invitation_only => '1' }
    end
    assert_response :success
    
    @walrus_attack_current.reload
    assert_equal old_desc, @walrus_attack_current.description
    assert !@walrus_attack_current.invitation_only
  end
  
end
