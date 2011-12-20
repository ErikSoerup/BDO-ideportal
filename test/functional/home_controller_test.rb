require File.dirname(__FILE__) + '/../test_helper'
require 'home_controller'

class HomeControllerTest < ActionController::TestCase
  def setup
    @controller = HomeController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  scenario :basic
  should route(:get, "/").to(:controller=>'home', :action => 'show')

  context "get show" do
    setup {get :show}
    should respond_with(:success)
    should assign_to(:body_class)
    should render_template 'show'
  end
  
end
