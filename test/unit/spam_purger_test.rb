require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'

SPAM_PURGE_AGE = 10

class SpamPurgerTest < ActiveSupport::TestCase
  scenario :basic
  
  def test_purger_preserves_newer_spam
    Time.stubs(:now).returns(Time.local(2008, 1, 20))
    assert_purger_deletes Idea => [], Comment => []
  end
  
  def test_purger_deletes_spam
    Time.stubs(:now).returns(Time.local(2008, 1, 25))
    assert_purger_deletes Idea => [@spam_idea.id], Comment => [@walrus_comment_spam.id]
  end
  
  def test_purger_deletes_spam_selectively
    Time.stubs(:now).returns(Time.local(2008, 1, 23))
    assert_purger_deletes Idea => [@spam_idea.id], Comment => []
  end
  
  def test_purger_deletes_associated
    @nonspam_comment_on_spam_idea = @spam_idea.comments.create!(add_client_info(
      :author => @sally,
      :text => "This idea is spam. Please delete."))
    @nonspam_admin_comment_on_spam_idea = @spam_idea.admin_comments.create!(
      :author => @sally,
      :text => "This idea is spam. Please delete.")
    @spam_idea_vote = @spam_idea.add_vote! @aaron
    @spam_idea.tags << @crazy_tag
    @spam_idea.admin_tags << @hire_this_person_tag
    @spam_idea.save!
    
    Time.stubs(:now).returns(Time.local(2008, 1, 25))
    assert_purger_deletes(
      Idea => [@spam_idea.id],
      Comment => [@walrus_comment_spam.id, @nonspam_comment_on_spam_idea.id],
      Vote => [@spam_idea_vote.id],
      AdminComment => [@nonspam_admin_comment_on_spam_idea.id])
    @crazy_tag.reload
    @hire_this_person_tag.reload
    assert !@crazy_tag.idea_ids.include?(@spam_idea.id)
    assert !@hire_this_person_tag.idea_ids.include?(@spam_idea.id)
  end

  def model_map(models)
    Hash[
      models.map do |model|
        [model, model.find(:all).map { |r| r.id }]
      end
    ]
  end
  
  def assert_purger_deletes(expected_deletions)
    ids_before = model_map(expected_deletions.keys)
    SpamPurger.run_all
    ids_after = model_map(expected_deletions.keys)
    
    expected_deletions.each do |model, deletions|
      assert_equal_unordered ids_before[model] - deletions, ids_after[model], "Wrong deletions for #{model}"
    end
  end
  
end
