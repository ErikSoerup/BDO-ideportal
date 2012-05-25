class Current < ActiveRecord::Base

  acts_as_authorizable

  unless !Current.table_exists?
    acts_as_tsearch :fields => %w(title description)
  end

  belongs_to :inventor, :class_name => 'User'
  has_many :ideas, :order => 'ideas.created_at' do
    def visible
      r = find :all, :conditions => { :hidden => false }
    end
  end
  has_and_belongs_to_many :subscribers, :join_table => 'currents_subscribers', :class_name => 'User'

  validates_presence_of :title, :description

  
  has_many :current_followers
  DEFAULT_CURRENT_ID = -1
  SUGESSIONS_ID = 6 #depends on the DB record id

  def self.all_except_default
<<<<<<< HEAD
    self.all.select do |current|
=======
    self.active.select do |current|
>>>>>>> 700984efbc1a57881f6ccdddaf3ff76d4c3a703d
      current.id != DEFAULT_CURRENT_ID
    end
  end

<<<<<<< HEAD
=======
  def self.active
    currs = Current.find(:all, :conditions => ["active = ?", true], :order => "id DESC")
    c = currs.pop
    currs = currs.reverse
    currs << c
    return currs
  end

>>>>>>> 700984efbc1a57881f6ccdddaf3ff76d4c3a703d
  def closed_or_expired?
    if closed? || expired?
      self.closed = true
    else
      return false
    end
  end

  def expired?
    !submission_deadline.nil? && submission_deadline < Date.today
  end

  def self.populate_idea_counts(currents)
    idea_counts = Idea.find :all,
      :select => 'count(*) as idea_count, current_id',
      :conditions => ['current_id in (?) and hidden = ?', currents.map{ |i| i.id }, false],
      :group => 'current_id'
    counts_by_id = Hash.new(0)
    idea_counts.each do |c|
      counts_by_id[c.current_id] = c.idea_count.to_i
    end
    currents.each do |current|
      current.idea_count = counts_by_id[current.id]
    end
  end

  attr_writer :idea_count

  def idea_count
    @idea_count ||= (attributes[:idea_count] || ideas.visible.size)
  end

end
