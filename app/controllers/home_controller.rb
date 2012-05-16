class HomeController < ApplicationController
  before_filter :login_required

  layout  :compute_layout


  def static_layout
    
  end

  
  def compute_layout

    if  action_name == "advance" || action_name == "main_search" || action_name == "show"
      'profile'
    elsif action_name == "static_layout"
      nil
    else
      'application'
    end
  end

  def index
    # render the landing page
  end

  def advance

    if params[:val] == "followers"
      if params[:arrow] == "up"
        @ideas=Idea.active.find(:all, :order => "ideas.created_at DESC").sort{|x,y| y.idea_followers.collect(&:user_id).uniq.count <=> x.idea_followers.collect(&:user_id).uniq.count}
        @ideas=@ideas.paginate(:page => params[:page],:per_page => 5)
      elsif params[:arrow] == "down"
        @ideas=Idea.active.find(:all, :order => "ideas.created_at DESC").sort{|x,y| x.idea_followers.collect(&:user_id).uniq.count <=> y.idea_followers.collect(&:user_id).uniq.count}
        @ideas=@ideas.paginate(:page => params[:page],:per_page => 5)
      end
    elsif params[:val] == "date"
      if params[:arrow] == "up"
        @ideas=Idea.active.paginate(:page => params[:page], :per_page => 5, :order => "ideas.created_at DESC")
      elsif params[:arrow] == "down"
        @ideas=Idea.active.paginate(:page => params[:page], :per_page => 5, :order => "ideas.created_at ASC")
      end
    elsif params[:val] == "comment"
      if params[:arrow] == "up"
        @ideas=Idea.active.find(:all, :order => "ideas.created_at DESC").sort{|x,y| y.comment_count <=> x.comment_count}
        @ideas=@ideas.paginate(:page => params[:page],:per_page => 5)
      elsif params[:arrow] == "down"
        @ideas=Idea.active.find(:all, :order => "ideas.created_at DESC").sort{|x,y| x.comment_count <=> y.comment_count}
        @ideas=@ideas.paginate(:page => params[:page],:per_page => 5)
      end
    elsif params[:val] == "vote"
      if params[:arrow] == "up"
        @ideas=Idea.active.find(:all, :order => "ideas.created_at DESC").sort{|x,y| y.vote_count <=> x.vote_count}
        @ideas=@ideas.paginate(:page => params[:page],:per_page => 5)
      elsif params[:arrow] == "down"
        @ideas=Idea.active.find(:all, :order => "ideas.created_at DESC").sort{|x,y| x.vote_count <=> y.vote_count}
        @ideas=@ideas.paginate(:page => params[:page],:per_page => 5)
      end
    else
      @ideas=Idea.active.find(:all, :order =>"ideas.created_at DESC")
      @ideas=@ideas.paginate(:page => params[:page], :per_page => 5)
    end


  end

  def main_search
    @ideas=[]
    params[:val1].each do |val|
      if val == "alle"
        @ideas << Idea.active.find(:all, :order => "ideas.created_at DESC")

        #    elsif params[:val1] == "de hotteste ideer"
        #      @ideas= Idea.populate_comment_counts(search_ideas(params))
      elsif val == "nye"
        @ideas <<  Idea.active.find(:all, :conditions => ['status=?', 'new'], :order => "ideas.created_at DESC")
        #    elsif params[:val1] == "under udvikling"
        #      @ideas=Idea.find(:all, :conditions => ['status=?', 'under review'])
      elsif val == "implementeret"
        @ideas << Idea.active.find(:all, :conditions => ['status=?', 'launched'], :order => "ideas.created_at DESC")
      elsif val == "under evaluering"
        @ideas << Idea.active.find(:all, :conditions => ['status=?', 'under review'], :order => "ideas.created_at DESC")
      elsif val == "ikke evalueret"
        @ideas << Idea.active.find(:all, :conditions => ['status=?', 'reviewed'], :order => "ideas.created_at DESC")
      elsif val == "comming"
        @ideas << Idea.active.find(:all, :conditions => ['status=?', 'coming soon'], :order => "ideas.created_at DESC")
      end

    end
    @ideas.flatten!
    puts @ideas.size
    @c_ideas=[]
    @m_ideas = []
    @d_ideas=[]

    params[:val2].each do |val2|
      if User.find_by_name(val2)

        @ideas.each do |idea|
          unless idea.inventor.nil?
            if idea.inventor == User.find_by_name(val2)

              @m_ideas << idea
            end

          end
        end

      else
        @ideas.each do |idea|
          @m_ideas << idea
        end

      end
    end

    params[:val3].each do |val3|
      if  val3 != "1"

        @m_ideas.each do |idea|
          unless idea.inventor.nil?
            if idea.inventor.department == Department.find_by_id(val3)
              @d_ideas << idea
            end
          end
        end
      else
        @m_ideas.each do | idea|
          @d_ideas << idea
        end
      end
    end
    params[:val4].each do |val4|
      if Current.all.collect(&:title).include?(val4) || val4 != "current"
        @current=Current.find_by_title(val4)
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
    end
    @count=@c_ideas.size
    if params[:val] == "followers"
      if params[:arrow] == "up"
        @c_ideas=@c_ideas.sort{|x,y| y.idea_followers.collect(&:user_id).uniq.count <=> x.idea_followers.collect(&:user_id).uniq.count}
        @total_ideas=@c_ideas
        @c_ideas=@c_ideas.paginate(:page => params[:page],:per_page => 5)
      elsif params[:arrow] == "down"
        @c_ideas=@c_ideas.sort{|x,y| x.idea_followers.collect(&:user_id).uniq.count <=> y.idea_followers.collect(&:user_id).uniq.count}
        @total_ideas=@c_ideas
        @c_ideas=@c_ideas.paginate(:page => params[:page],:per_page => 5)
      end
    elsif params[:val] == "date"
      if params[:arrow] == "up"
        @c_ideas=@c_ideas.paginate(:page => params[:page], :per_page => 5, :order => "ideas.created_at DESC")
        @total_ideas=@c_ideas
      elsif params[:arrow] == "down"
        @c_ideas=@c_ideas.paginate(:page => params[:page], :per_page => 5, :order => "ideas.created_at ASC")
        @total_ideas=@c_ideas
      end
    elsif params[:val] == "comment"
      if params[:arrow] == "up"
        @c_ideas=@c_ideas.sort{|x,y| y.comment_count <=> x.comment_count}
        @total_ideas=@c_ideas
        @c_ideas=@c_ideas.paginate(:page => params[:page],:per_page => 5)
      elsif params[:arrow] == "down"
        @c_ideas=@c_ideas.sort{|x,y| x.comment_count <=> y.comment_count}
        @total_ideas=@c_ideas
        @c_ideas=@c_ideas.paginate(:page => params[:page],:per_page => 5)
      end
    elsif params[:val] == "vote"
      if params[:arrow] == "up"
        @c_ideas=@c_ideas.sort{|x,y| y.vote_count <=> x.vote_count}
        @total_ideas=@c_ideas
        @c_ideas=@c_ideas.paginate(:page => params[:page],:per_page => 5)
      elsif params[:arrow] == "down"
        @c_ideas=@c_ideas.sort{|x,y| x.vote_count <=> y.vote_count}
        @total_ideas=@c_ideas
        @c_ideas=@c_ideas.paginate(:page => params[:page],:per_page => 5)
      end
    else
      @total_ideas=@c_ideas
      @c_ideas=@c_ideas.paginate(:page => params[:page], :per_page => 5)
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

