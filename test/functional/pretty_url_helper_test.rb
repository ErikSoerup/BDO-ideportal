require File.dirname(__FILE__) + '/../test_helper'

class PrettyUrlHelperTest < ActionController::TestCase
  
  scenario :basic
  
  def setup
    @controller = IdeasController.new
    get :index  # initializes routing behavior in tests
  end
  
  def test_idea
    @barbershop_discount.id = 1000000
    
    assert_equal "/ideas/1000000/discounts-for-barbershop-quartets",                 idea_path(@barbershop_discount)
    assert_equal "/ideas/1000000/discounts-for-barbershop-quartets?foo=bar",         idea_path(@barbershop_discount, :foo => 'bar')
    assert_equal "http://test.host/ideas/1000000/discounts-for-barbershop-quartets", idea_url(@barbershop_discount)
    assert_equal "/ideas/1000000",                 idea_path(@barbershop_discount, :title_in_url => false)
    assert_equal "/ideas/1000000?foo=bar",         idea_path(@barbershop_discount, :title_in_url => false, :foo => 'bar')
    assert_equal "http://test.host/ideas/1000000", idea_url(@barbershop_discount, :title_in_url => false)
  end
  
  def test_profile
    @sally.id = 1000000
    
    assert_equal "/profiles/1000000/sally-otest",                 profile_path(@sally)
    assert_equal "/profiles/1000000/sally-otest?foo=bar",         profile_path(@sally, :foo => 'bar')
    assert_equal "http://test.host/profiles/1000000/sally-otest", profile_url(@sally)
    assert_equal "/profiles/1000000",                 profile_path(@sally, :title_in_url => false)
    assert_equal "/profiles/1000000?foo=bar",         profile_path(@sally, :title_in_url => false, :foo => 'bar')
    assert_equal "http://test.host/profiles/1000000", profile_url(@sally, :title_in_url => false)
  end
  
  def test_current
    @walrus_attack_current.id = 1000000
    
    assert_equal "/currents/1000000/dealing-with-walruses",                 current_path(@walrus_attack_current)
    assert_equal "/currents/1000000/dealing-with-walruses?foo=bar",         current_path(@walrus_attack_current, :foo => 'bar')
    assert_equal "http://test.host/currents/1000000/dealing-with-walruses", current_url(@walrus_attack_current)
    assert_equal "/currents/1000000",                 current_path(@walrus_attack_current, :title_in_url => false)
    assert_equal "/currents/1000000?foo=bar",         current_path(@walrus_attack_current, :title_in_url => false, :foo => 'bar')
    assert_equal "http://test.host/currents/1000000", current_url(@walrus_attack_current, :title_in_url => false)
  end
  
end
