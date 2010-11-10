require 'ostruct'

module Admin
  class GraphsController < AdminController
    def show
    end
    
    ALLOWED_MODELS = [Idea, Comment, Vote]
    
    def graph_data_for(model, start_time = 6.months.ago, end_time = Time.new)
      raise "Illegal parameter: model must be one of #{ALLOWED_MODELS.inspect}" unless ALLOWED_MODELS.include?(model)
      
      bucket_size = 'day' # for DB
      bucket_step = 1.day # for filling gaps
    
      # The following (probably) works only on PostgreSQL. Patches for other DBs welcome.
      populated_buckets = model.find :all,
        :select => "count(*) as count, date_trunc('#{bucket_size}', created_at) as date",
        :conditions => ['created_at > ? and created_at < ?', start_time, end_time],
        :group => 'date',
        :order => 'date'
      populated_buckets.map! { |b| StatsBucket.new(Time.parse(b.date).getutc, b.count.to_i) }
      
      # The DB only returns buckets with nonzero counts. We want to construct a list of all
      # buckets, zero or otherwise. This is complicated by the fact that, because of DST,
      # the database buckets' start times are not necessarily at perfectly even intervals.
      #
      # The following is a linear-time algorithm for filling in the empty spaces between
      # buckets, guaranteeing that the buckets cover the interval from start_time to end_time,
      # in increments no larger than bucket_step * 1.5, while preserving the DB's precise timestamps.
      
      if populated_buckets.empty? || populated_buckets.last.date < end_time
        populated_buckets << StatsBucket.new(end_time, 0)
      end
      t = [start_time, populated_buckets.first.date].min
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
      buckets.map { |bucket| "[#{bucket.date.getutc.to_f * 1000}, #{bucket.count}]" }.join(",")
    end
    helper_method :graph_data_for
  
    class StatsBucket
      attr_accessor :date, :count
    
      def initialize(date, count)
        @date, @count = date, count
      end
    end
  end
  
end


