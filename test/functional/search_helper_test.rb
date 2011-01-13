require File.dirname(__FILE__) + '/../test_helper'

DEFAULT_ZIP_CODE = '55102'

class SearchHelperTest < ActionController::TestCase
  scenario :basic
  
  include SearchHelper
  
  def test_search_recent
    assert_equal_unordered [@barbershop_discount, @walruses_in_stores, @tranquilizer_guns, @give_up_all_hope], search_ideas(:search => ['recent'])
  end
  
  def test_search_tag
    assert_equal_unordered [@walruses_in_stores], search_ideas(:search => ['tag', 'walrussy'])
  end
  
  def test_search_current    
    assert_equal_unordered [@tranquilizer_guns, @give_up_all_hope], search_ideas(:search => ['current', @walrus_attack_current.id]) 
  end
  
  def test_search_text_title
    assert_equal_unordered [@walruses_in_stores], search_ideas(:search_text => 'release')
    assert_equal_unordered [@barbershop_discount], search_ideas(:search_text => 'barbershop')
  end

  def test_search_text_description
    assert_equal_unordered [@walruses_in_stores], search_ideas(:search_text => 'roam')
    assert_equal_unordered [@walruses_in_stores, @barbershop_discount], search_ideas(:search_text => 'store')
  end

  def test_search_text_tags
    assert_equal_unordered [@walruses_in_stores], search_ideas(:search_text => 'walrussy')
    assert_equal_unordered [@walruses_in_stores, @barbershop_discount], search_ideas(:search_text => 'crazy')
  end

  def test_search_text_admin_tags
    assert_equal_unordered [@barbershop_discount], search_ideas(:search_text => 'hire')
  end
  
  def test_search_multiword
    # If this test is failing and we're still using tsearch, make sure that patch is applied to make
    # acts_as_tsearch use plainto_tsquery instead of to_tsquery
    assert_equal_unordered [@barbershop_discount], search_ideas(:search_text => 'crazy moral')
  end

  # Commenting out until we figure out a solution that doesn't expose us to SQL Injection
  # def test_search_text_user_email
  #   assert_equal_unordered [@aaron], search(User, :search_text => 'aaron@example.com') { |x| x }
  # end

  def test_search_near_postal_code
    postal_code = @quentin.zip_code
    assert_equal [@walruses_in_stores], Idea.find(geo_search_ideas(:postal_code => postal_code))
  end
  
  def test_search_near_bogus_postal_code
    postal_code = 'foobar'
    assert_equal [], geo_search_ideas(:postal_code => postal_code)
  end
  
  def test_search_near_user
    @user = @quentin
    assert_equal [@walruses_in_stores], Idea.find(geo_search_ideas(:postal_code => 'user'))
  end
  
  def test_search_near_user_not_logged_in
    @user = nil
    assert_equal_unordered [@tranquilizer_guns, @give_up_all_hope], Idea.find(geo_search_ideas(:postal_code => 'user'))
  end
  
  def test_search_near_loc
    assert_equal_unordered [@walruses_in_stores],                   Idea.find(geo_search_ideas(:loc => '33.1, -80.5'))
    assert_equal_unordered [@tranquilizer_guns, @give_up_all_hope], Idea.find(geo_search_ideas(:loc => '36.0, -91.0'))
  end
  
  def test_search_text_spam_option
    params = {:search => "walrus"}
  
    text_result = search(Idea, params) do |results|
      results
    end
    assert_equal [@walruses_in_stores, @give_up_all_hope], text_result
  end
  
  def test_search_single_scare_quote
    assert_nothing_raised(ActiveRecord::StatementInvalid) {
      search_ideas(:search_text => '"')
    }
  end
  
  def test_search_empty_scare_quotes
    assert_nothing_raised(ActiveRecord::StatementInvalid) {
      search_ideas(:search_text => '""')
    }
  end
  
  def current_user
    @user
  end
  
  def logged_in?
    !!@user
  end
  
end
