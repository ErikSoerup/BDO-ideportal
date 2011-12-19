class HomeController < ApplicationController
  before_filter :login_required
 
  layout  :compute_layout
   
  def compute_layout
   
    if  action_name == "advance" || action_name == "main_search" || action_name == "show"
      'profile'
      
    else
      'application'
    end
  end

  def index
    # render the landing page
  end

  
  def advance
    
    if params[:val] == "person"
      if params[:arrow] == "up"
        @ideas=Idea.paginate(:page => params[:page], :per_page => 10, :order => "ideas.title DESC")
      elsif params[:arrow] == "down"
        @ideas=Idea.paginate(:page => params[:page], :per_page => 10, :order => "ideas.title ASC")
      end
    elsif params[:val] == "date"
      if params[:arrow] == "up"
        @ideas=Idea.paginate(:page => params[:page], :per_page => 10, :order => "ideas.created_at DESC")
      elsif params[:arrow] == "down"
        @ideas=Idea.paginate(:page => params[:page], :per_page => 10, :order => "ideas.created_at ASC")
      end
    elsif params[:val] == "comment"
      if params[:arrow] == "up"
        @ideas=Idea.find(:all).sort{|x,y| y.comment_count <=> x.comment_count}
        @ideas=@ideas.paginate(:per_page => 10)
      elsif params[:arrow] == "down"
        @ideas=Idea.find(:all).sort{|x,y| x.comment_count <=> y.comment_count}
        @ideas=@ideas.paginate(:per_page => 10)
      end
    elsif params[:val] == "vote"
      if params[:arrow] == "up"
        @ideas=Idea.find(:all).sort{|x,y| y.vote_count <=> x.vote_count}
        @ideas=@ideas.paginate(:per_page => 10)
      elsif params[:arrow] == "down"
        @ideas=Idea.find(:all).sort{|x,y| x.vote_count <=> y.vote_count}
        @ideas=@ideas.paginate(:per_page => 10)
      end
    else
      @ideas=Idea.paginate(:page => params[:page], :per_page => 10)
    end
    
    #where is the pagination code ???
    #    @body_class = 'advance'
    #    if params[:val] == "alle"
    #      @ideas=Idea.paginate(:page => params[:page], :per_page => 10)

    #    elsif params[:val] == "de hotteste ideer"
    #      @ideas= Idea.populate_comment_counts(search_ideas(params))
    #    elsif params[:val] == "nye"
    #      @ideas= Idea.populate_comment_counts(search_ideas(params))
    #    elsif params[:val] == "under udvikling"
    #      @ideas=Idea.paginate(:all, :conditions => ['status=?', 'under review'], :page => params[:page], :per_page => 10)
    #    elsif params[:val] == "implementeret"
    #      @ideas=Idea.paginate(:all, :conditions => ['status=?', 'reviewed'], :page => params[:page])
    #    elsif params[:val] == "under evaluering"
    #      @ideas=Idea.paginate(:all, :conditions => ['status=?', 'coming soon'], :page => params[:page])
    #    elsif params[:val] == "ikke evalueret"
    #      @ideas=Idea.paginate(:all, :conditions => ['status=?', 'launched'], :page => params[:page])
    #    elsif params[:val] == "min egne"
    #      @ideas=current_user.ideas.paginate(:page => params[:page])
    #    elsif params[:val] == "current"
    #      @current_ideas = Current.paginate(:all, :conditions=>"id != #{Current::DEFAULT_CURRENT_ID}", :page => params[:page])
    #    elsif params[:val] == "top"
    #      @users=User.find_top_contributors
    #      @ideas=[]
    #      @users.each do |u|
    #        @ideas << u.ideas unless u.ideas.empty?
    #      end
    #      @ideas=@ideas.first.paginate(:page => params[:page])
    #    elsif Current.all.collect(&:title).include?(params[:val])
    #      @current=Current.find_by_title(params[:val])
    #      @ideas=@current.ideas.paginate(:page => params[:page])
    #      
    #    elsif params[:val]
    #      @dep= Department.find_by_id(params[:val])
    #      val=[]
    #      unless @dep.users.empty?
    #        @dep.users.each do |user|
    #          val << user.ideas unless user.ideas.empty?
    #          @idea={@dep.id => val} unless val.empty?
    #        end
    #        @ideas=@idea.values.first.first.paginate(:page => params[:page]) 
    #      end
    #     
    #      
    #    else 
    #    end
  end


  def main_search
    @m_ideas=[]
    
    if params[:val1] == "alle"
      @ideas=Idea.all

#    elsif params[:val1] == "de hotteste ideer"
#      @ideas= Idea.populate_comment_counts(search_ideas(params))
    elsif params[:val1] == "nye"
      @ideas= Idea.find(:all, :conditions => ['status=?', 'new'])
#    elsif params[:val1] == "under udvikling"
#      @ideas=Idea.find(:all, :conditions => ['status=?', 'under review'])
    elsif params[:val1] == "implementeret"
      @ideas=Idea.find(:all, :conditions => ['status=?', 'launched'])
    elsif params[:val1] == "under evaluering"
      @ideas=Idea.find(:all, :conditions => ['status=?', 'under review'])
    elsif params[:val1] == "ikke evalueret"
      @ideas=Idea.find(:all, :conditions => ['status=?', 'reviewed'])
    elsif params[:val1] == "comming"
      @ideas=Idea.find(:all, :conditions => ['status=?', 'coming soon'])
    end
     @c_ideas=[]        
    @m_ideas = []
    @d_ideas=[]
    if params[:val2] == "min egne"
      
      @ideas.each do |idea|
        unless idea.inventor.nil?
          if idea.inventor == current_user
            
            @m_ideas << idea  
          end  
        end
      end

    else
      @ideas.each do |idea|
        @m_ideas << idea
      end
    end
    
    
    
    if  params[:val3] != "1" 
      
      @m_ideas.each do |idea|
        unless idea.inventor.nil?
          if idea.inventor.department == Department.find_by_id(params[:val3]) || idea.inventor.department.name == "default"
            @d_ideas << idea
          end
        end
      end
    else
      @m_ideas.each do | idea|
        @d_ideas << idea
      end
    end
    
    if Current.all.collect(&:title).include?(params[:val4]) || params[:val4] != "current"
      @current=Current.find_by_title(params[:val4])
      @d_ideas.each do |idea|
        if @current.ideas.include?(idea)
          @c_ideas << idea
        end
      end
    else
      @d_ideas.each do |idea|
        @c_ideas << idea
      end
      
    end
    
    if params[:val] == "person"
      if params[:arrow] == "up"
        @c_ideas=@c_ideas.paginate(:page => params[:page], :per_page => 10, :order => "ideas.title DESC")
      elsif params[:arrow] == "down"
        @c_ideas=@c_ideas.paginate(:page => params[:page], :per_page => 10, :order => "ideas.title ASC")
      end
    elsif params[:val] == "date"
      if params[:arrow] == "up"
        @c_ideas=@c_ideas.paginate(:page => params[:page], :per_page => 10, :order => "ideas.created_at DESC")
      elsif params[:arrow] == "down"
        @c_ideas=@c_ideas.paginate(:page => params[:page], :per_page => 10, :order => "ideas.created_at ASC")
      end
    elsif params[:val] == "comment"
      if params[:arrow] == "up"
        @c_ideas=@c_ideas.paginate(:page => params[:page], :per_page => 10).sort{|x,y| x.comment_count <=> y.comment_count}
      elsif params[:arrow] == "down"
        @c_ideas=@c_ideas.paginate(:page => params[:page], :per_page => 10).sort{|x,y| y.comment_count <=> x.comment_count}
      end
    elsif params[:val] == "vote"
      if params[:arrow] == "up"
        @c_ideas=@c_ideas.paginate(:page => params[:page], :per_page => 10).sort{|x,y| y.vote_count <=> x.vote_count}
      elsif params[:arrow] == "down"
        @c_ideas=@c_ideas.paginate(:page => params[:page], :per_page => 10).sort{|x,y| x.vote_count <=> y.vote_count}
      end
    else
      @c_ideas=@c_ideas.paginate(:page => params[:page], :per_page => 10)
    end
    
    
    #    end  
  end 

  
  
  def current_objects
    @currrents ||= Current.find(:all, :conditions=>"id != #{Current::DEFAULT_CURRENT_ID}")
  end
  def show
    @body_class = params[:page].nil? ? 'home' : params[:page]
    render :action => params[:page] || 'show'
  end

  def nearby_ideas
    ideas = Idea.find(geo_search_ideas(params[:search], :limit => 5))
    render :partial => 'idea', :collection => ideas
  end

  # Experimental wacky fractal tag cloud (currently unused):

  def render_idea_cloud(opts)
    logger.warn("selecting idea cloud!")
    @cloud_layout = nil
    opts[:searches].each do |search|
      new_ideas = search_ideas(:page_size => opts[:count], :search => search)
      new_cloud = cloud(new_ideas, opts.merge(:search => search))
      if @cloud_layout
        @cloud_layout.merge!(new_cloud)
      else
        @cloud_layout = new_cloud
      end
    end
    render :partial => 'cloud', :locals => opts.merge(:boxes => @cloud_layout.boxes)
  end
  helper_method :render_idea_cloud

  def cloud(ideas, opts = {})
    top_rated = opts[:search].include?('hot')
    opts.reverse_merge!(
      :density           => 0.5,
      :favor_largest     => 0.4,
      :placements        => [0, 1, 0, 1],
      :initial_placement => top_rated ? [0, 0] : [1, 1],
      :color_scheme      => Layout::GradientColorScheme.new(
        if top_rated
          ['ff2d16', 'ff7600', 'ffb46e', 'ffffff']
        else
          ['152333', '005f86', '85dfe2', 'ffffff']
        end))
    idea_sizer = if top_rated
      lambda { |idea| (idea.rating + 1) ** 0.5 }
    else
      lambda { |idea| (ideas.size / (ideas.index(idea) + 1.0) - 0.9) ** 1 }
    end
    Layout::FractalScatter.new(ideas, opts, &idea_sizer)
  end

  def cloud_style(boxes)
    idea = boxes.object
    " font-size: #{Math.sqrt(boxes.area / (idea.title.size + 1)) * 0.9}px;
      line-height: 0.9em;
      text-align: center;
      /*overflow: hidden;
      text-overflow: ellipsis;*/

      color: #{boxes.color};

      position: absolute;
      left:   #{boxes.left}px;
      top:    #{boxes.top}px;
      width:  #{boxes.width}px;
      height: #{boxes.height}px
    ".gsub(/[\r\n]/, '')
  end
  helper_method :cloud_style

  include ApplicationHelper

end

