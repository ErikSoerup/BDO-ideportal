require File.dirname(__FILE__) + '/../test_helper'
# require 'admin/chronologies_controller'

class Admin::ChronologiesControllerTest < ActionController::TestCase
  scenario :basic
  
  def setup
    @controller = Admin::ChronologiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_index
    assert_admin_required 'You must log in as an administrator to view chronologies in the admin interface.' do
      get :show
    end
    assert_response :success
    assert_template 'admin/chronologies/show'
    # assert_tag :attributes => { :onclick => /#{edit_admin_current_path(@walrus_attack_current)}/ }
    # assert_tag :content => @walrus_attack_current.title
    # assert_tag :content => @walrus_attack_current.description
    # assert_tag :content => @walrus_attack_current.description
    # assert_tag :tag => 'a', :attributes => { :href => new_admin_current_path }
  end
  
end
