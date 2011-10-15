require File.dirname(__FILE__) + '/../test_helper'

class IdeaObserverTest < ActiveSupport::TestCase
  
  scenario :basic
  
  def setup
    @deliveries = ActionMailer::Base.deliveries = []
  end
  
  def test_idea_entering_life_cycle_step_notifies_admins
    @admin_user.update_attribute(:notify_on_state, true)
    @walruses_in_stores.update_attributes(:life_cycle_step_id => @bad_idea_mock.id)
    
    assert_equal 1, @deliveries.size
    sent = @deliveries.shift
    assert_equal [@admin_user.email], sent.to
    assert sent.body =~ /A new idea requires your attention/
  end
  
end
