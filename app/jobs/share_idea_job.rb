class ShareIdeaJob
  
  attr_accessor :idea_id, :idea_url
  
  def initialize(idea, idea_url)
    @idea_id = idea.id
    @idea_url = idea_url  # need to get it here because we don't have access to the idea_url method
  end
  
  def perform
    Timeout::timeout(30) do
      share_idea Idea.find(idea_id)
    end
  end
  
  include ActionView::Helpers::TextHelper # for truncate
  
end
