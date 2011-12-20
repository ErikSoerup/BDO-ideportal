module Admin
  module GraphHelper
    
    def idea_graph_data
      graph_data_for Idea, 'not hidden and inventor_id is not null'
    end
    
    def comment_graph_data
      graph_data_for Comment, 'not hidden'
    end
    
    def vote_graph_data
      graph_data_for Vote
    end
    
  private
    
    def graph_data_for(model, extra_conditions = '', start_time = 6.months.ago, end_time = Time.now)
      bucket_size = 'day' # for DB
      bucket_step = 1.day # for filling gaps
      
      # Move start_time to the previous day boundary, so that the bucket timestamps are correct
      start_time = Time.local(start_time.year, start_time.month, start_time.day)
    
      # The following query (probably) works only on PostgreSQL. Patches for other DBs welcome.
      extra_conditions = ' and ' + extra_conditions unless extra_conditions.blank?
      populated_buckets = model.find :all,
        :select => "count(*) as count, date_trunc('#{bucket_size}', created_at at time zone 'UTC') as date",
        :conditions => ['created_at >= ? and created_at < ?' + extra_conditions, start_time.getutc - 1.day, end_time.getutc],
        :group => 'date',
        :order => 'date'
      populated_buckets.map! { |b| StatsBucket.new(Time.parse(b.date), b.count.to_i) }
      
      # The DB only returns buckets with nonzero counts. We want to construct a list of all
      # buckets, zero or otherwise. This is complicated by the fact that, because of DST,
      # the database buckets' start times are not necessarily at perfectly even intervals.
      #
      # The following is a linear-time algorithm for filling in the empty spaces between
      # buckets, guaranteeing that the buckets cover the interval from start_time to end_time,
      # in increments no larger than bucket_step * 1.5. The buckets always have timestamps
      # at midnight in local time (i.e. respecting DST).
      #
      # An additional complication comes from the fact that the client doesn't know what time zone
      # the serer is using. Flot's solution to this is to use only UTC millisecond offsets, and then
      # display dates as if the local time were UTC. That means that we need to make the time zone
      # correction here on the server.
      #
      # Follow all of that? Then you've been sitting at the computer to long!
      # Heaven knows I have. Go stretch your legs! -PPC
      
      if populated_buckets.empty? || populated_buckets.last.date < end_time
        populated_buckets << StatsBucket.new(end_time, 0)
      end
      t = start_time
      populated_buckets.shift while !populated_buckets.empty? && populated_buckets.first.date < t
      buckets = []
      populated_buckets.each do |bucket|
        fill_to = bucket.date - bucket_step / 2
        while t < fill_to
          buckets << StatsBucket.new(t, 0)
          t += bucket_step
        end
        buckets << bucket
        t = bucket.date + bucket_step
      end
      buckets.delete_at(-1) # last bucket will be bogus
      buckets.map { |bucket| "[#{(bucket.date.getutc.to_f + bucket.date.utc_offset) * 1000}, #{bucket.count}]" }.join(",")
    end
  
    class StatsBucket
      attr_accessor :date, :count
    
      def initialize(date, count)
        @date, @count = date, count
      end
    end
  end
  
end


