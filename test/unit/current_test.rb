require File.dirname(__FILE__) + '/../test_helper'

class CurrentTest < ActiveSupport::TestCase
  scenario :basic
  
  def test_required_fields
    test_current_field_error :title, nil
    test_current_field_error :title, ''
    test_current_field_error :description, nil
    test_current_field_error :description, ''
  end
  
  def test_default_current
    #assert_equal Current::DEFAULT_CURRENT_ID, @orphan_idea.current_id
  end
  
  def test_inventor_relationship
    assert_equal @admin_user, @walrus_attack_current.inventor
    assert_equal [@walrus_attack_current], @admin_user.currents
  end
  
  def test_idea_relationship
    assert_equal_unordered [@tranquilizer_guns, @give_up_all_hope, @hidden_idea], @walrus_attack_current.ideas
    assert_equal_unordered [@tranquilizer_guns, @give_up_all_hope],               @walrus_attack_current.ideas.visible
    
    @barbershop_discount.current = @walrus_attack_current  
    @barbershop_discount.save!
    @walrus_attack_current.reload
    assert_equal_unordered [@tranquilizer_guns, @give_up_all_hope, @barbershop_discount, @hidden_idea], @walrus_attack_current.ideas    
    assert_equal_unordered [@tranquilizer_guns, @give_up_all_hope, @barbershop_discount],               @walrus_attack_current.ideas.visible   
  end
  
  def test_closed_or_expired
    assert_equal false, @walrus_attack_current.closed?
    assert_equal true,  @walrus_attack_current.submission_deadline >= Date.today
    assert_equal false, @walrus_attack_current.closed_or_expired?
    
    # Even if .closed? returns false, closed_or_expired should return true
    assert_equal false, @expired_current.closed?
    assert_equal true, @expired_current.submission_deadline < Date.today
    
    assert_equal true, @expired_current.closed_or_expired?
    assert_equal true, @expired_current.closed?  # closed_or_expired should set closed = true
  end
  
  def test_populate_idea_counts
    Current.populate_idea_counts [@walrus_attack_current]
    assert_equal 2, @walrus_attack_current.idea_count
  end
  
  def test_idea_count_does_not_include_hidden_comments
    assert_equal 3, @walrus_attack_current.ideas.size
    assert_equal 2, @walrus_attack_current.idea_count
  end
  
  def test_roles_for_currents
    assert @currents_admin.has_role? 'admin', Current
    assert @participator.has_role? 'invitee', @private_current
    assert_equal [@private_current], @participator.is_invitee_in_what
    assert_equal [@participator], @private_current.has_invitees
  end
  
  def test_subscriber_relationship
    assert_equal_unordered [@sally], @walrus_attack_current.subscribers
    assert_equal_unordered [@walrus_attack_current], @sally.subscribed_currents
  end
  
private

  def test_current_field_error(field, value)
    test_field_error Current, field, value,
      :inventor => @quentin,
      :title => 'foo',
      :description => 'bar'
  end

end

