require File.dirname(__FILE__) + '/../test_helper'

require 'mocha'

class SearchHelperTest < ActionController::TestCase
  scenario :basic
  
  include Admin::GraphHelper
  
  def setup
    Time.stubs(:now).returns(Time.local(2008, 5, 6, 3, 17))
  end
  
  # Checking that:
  #  - buckets fall correctly on day boundaries,
  #  - things show up in the correct bucket, and
  #  - hidden ideas & comments are not counted.
  # Note that test_helper sets the time zone for all tests to US/Central.
  
  def test_idea_graph_data
    check_bucket_counts(
      parse_graph_data(idea_graph_data),
      1199145600000.0 => 2,
      1199318400000.0 => 1)
  end

  def test_comment_graph_data_and_daylight_savings_crossing
    # Arrange the comment timestamps so that they cross a DST boundary
    @walrus_comment1.created_at = Time.local(2008, 3, 9, 23, 59)
    @walrus_comment1.save!
    @walrus_comment2.created_at = Time.local(2008, 3, 10, 0, 0)
    @walrus_comment2.save!
    @comment_on_hidden_idea.created_at = Time.local(2008, 3, 10, 23, 59)
    @comment_on_hidden_idea.save!
    @walrus_comment_spam.created_at = Time.local(2008, 3, 10, 0, 0)
    @walrus_comment_spam.save!
    @hidden_comment.created_at = Time.local(2008, 4, 1)
    @hidden_comment.save!
    
    check_bucket_counts(
      parse_graph_data(comment_graph_data),
      1205020800000.0 => 1,
      1205107200000.0 => 2)
  end

  def test_vote_graph_data
    vote1 = @walruses_in_stores.add_vote!(@sally)
    vote2 = @walruses_in_stores.add_vote!(@quentin)
    vote3 = @barbershop_discount.add_vote!(@quentin)
    
    vote1.created_at = Time.local(2008, 5, 1, 0, 0)
    vote1.save!
    vote2.created_at = Time.local(2008, 5, 1, 23, 59)
    vote2.save!
    vote3.created_at = Time.local(2008, 5, 2, 0, 0)
    vote3.save!
    
    check_bucket_counts(
      parse_graph_data(vote_graph_data),
      1209600000000.0 => 2,
      1209686400000.0 => 1)
  end

  def test_bucket_dates_match
    @walrus_comment1.created_at = Time.local(2007, 11, 5)
    @walrus_comment1.save!
    @walrus_comment2.created_at = Time.local(2007, 11, 6)
    @walrus_comment2.save!
    @comment_on_hidden_idea.created_at = Time.local(2007, 5, 6)
    @comment_on_hidden_idea.save!
    
    idea_times    = parse_graph_data(   idea_graph_data).map { |time, count| time }  # nonzero counts in the middle
    comment_times = parse_graph_data(comment_graph_data).map { |time, count| time }  # nonzero counts at the beginning & end
    vote_times    = parse_graph_data(   vote_graph_data).map { |time, count| time }  # buckets all empty
    
    assert_equal idea_times, comment_times
    assert_equal comment_times, vote_times
  end

private

  def parse_graph_data(data)
    # Careful: for testing puroses only! Do not copy into production code.
    eval '[' + data + ']'
  end
  
  def check_bucket_counts(buckets, expected_counts)
    actual_counts = {}
    buckets.each do |t, count|
      actual_counts[t] = count
      time = Time.at(t / 1000).getutc
      assert_equal '00:00:00', time.strftime('%H:%M:%S'), "Time is not at midnight: #{time}"
    end
    
    expected_counts.each do |t, expected_count|
      actual_count = actual_counts[t]
      unless actual_count
        raise "Expected bucket for time #{t}, but no bucket found. Buckets: #{actual_counts.keys.join(', ')}"
      end
      assert_equal expected_count, actual_count, "Wrong count for bucket at time #{t}"
      actual_counts.delete t
    end
    
    actual_counts.each do |t, actual_count|
      assert_equal 0, actual_count, "Found unexpected nonzero count at time #{t}"
    end
  end

end
