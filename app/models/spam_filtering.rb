module SpamFiltering
  def self.included(klass)
    klass.class_eval do
      has_rakismet :author       => proc { user_for_spam_filtering.name },
                   :author_email => proc { user_for_spam_filtering.email },
                   :user_ip    => :ip,
                   :user_agent => :agent,
                   :content    => :text,
                   :permalink  => proc { Rakismet::URL + '/' + self.class.name.pluralize.underscore + '/' + self.id }
  
      validates_presence_of :ip, :on => :create
      validates_presence_of :user_agent, :on => :create
    end
  end
  
  def marked_spam=(spam)
    self[:marked_spam] = spam
    self[:hidden] = true if spam
  end
  
  def check_spam!
    if Rakismet::KEY
      Timeout::timeout(60) do
        self.marked_spam ||= self.spam?
        self.save!
      end
    end
  end
end
