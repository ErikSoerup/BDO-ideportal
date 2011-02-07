class SpamPurger < BatchWorker
  
  MAX_RUNS = 100         # How many times should we run before giving up on updating everything?
  BATCH_SIZE = 50        # How many records should we attempt to modify in a single transaction?
  
  def self.workers(config)
    [ SpamPurger.new(Idea),
      SpamPurger.new(Comment)]
  end
  
  def initialize(model)
    @model = model
    @purge_cutoff = SPAM_PURGE_AGE.days.ago
  end
  
  def run
    return unless SPAM_PURGE_AGE
    
    @model.transaction do
      spams = @model.find :all,
        :conditions => ['marked_spam = ? and updated_at < ?', true, @purge_cutoff],
        :limit => BATCH_SIZE
      
      spams.each do |spam|
        logger.info "Purging spam #{spam.class}##{spam.id}"
        spam.destroy
      end
      
      !spams.empty?
    end
  end
  
  def to_s
    "#{self.class.name}[#{@model.name}]"
  end
  
end
