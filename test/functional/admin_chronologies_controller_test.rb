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
    @walrus_comment1.created_at = Time.local(2008, 1, 4)
    @walrus_comment1.save!
    @walrus_comment2.created_at = Time.local(2008, 1, 5)
    @walrus_comment2.save!
    @comment_on_hidden_idea.created_at = Time.local(2008, 1, 4)
    @comment_on_hidden_idea.save!
    @walrus_comment_spam.created_at = Time.local(2008, 1, 5)
    @walrus_comment_spam.save!
    
    vote1 = @walruses_in_stores.add_vote!(@sally)
    vote2 = @walruses_in_stores.add_vote!(@quentin)
    vote1.created_at = Time.local(2008, 1, 2, 0, 0)
    vote1.save!
    vote2.created_at = Time.local(2007, 12, 31, 23, 59, 59)
    vote2.save!

    assert_admin_required 'You must log in as an administrator to view chronologies in the admin interface.' do
      get :show, { :from => '1199145600000.0', :to => '1199404800000.0' }
    end
    assert_response :success
    assert_template 'admin/chronologies/show'
    
    assert_idea_shown true, @walruses_in_stores
    assert_idea_shown true, @barbershop_discount
    assert_idea_shown false, @hidden_idea
    assert_idea_shown false, @spam_idea
    assert_idea_shown true, @duplicate_idea
    
    assert_comment_shown true, @walrus_comment1
    assert_comment_shown false, @walrus_comment2
    assert_comment_shown true, @comment_on_hidden_idea
    assert_comment_shown false, @walrus_comment_spam
    
    assert_vote_shown true, vote1
    assert_vote_shown false, vote2
  end

private
  
  def assert_idea_shown(shown, idea)
    assert_action_shown shown, edit_admin_idea_path(idea),
      ['Idea', idea.inventor.name, idea.description]
  end
  
  def assert_comment_shown(shown, comment)
    assert_action_shown shown, edit_admin_comment_path(comment),
      ['Comment', comment.author.name, /Re:\s+#{comment.idea.title}/, comment.text]
  end

  def assert_vote_shown(shown, vote)
    assert_action_shown shown, edit_admin_user_path(vote.user),
      ['Vote', vote.user.name, /Re:\s+#{vote.idea.title}/]
  end
  
  def assert_action_shown(shown, url, text_children)
    assert_method = shown ? :assert_tag : :assert_no_tag
    parent_tag = {:attributes => {:onclick => /#{url}/}}
    text_children.each do |text_child|
      self.send assert_method, parent_tag.merge(:descendant => {:content => text_child})
    end
  end
  
end
