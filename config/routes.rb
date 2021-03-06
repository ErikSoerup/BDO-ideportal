ActionController::Routing::Routes.draw do |map|
  map.resources :ideas, :member => { :destroy_idea => :delete,:assign => :post, :subscribe => :post, :followers => :get, :unsubscribe => [:post, :get], :unfollow => :delete } do |idea|  # unsubscribe supports GET for direct link from e-mail
    idea.resources :comments # for new/create, idea-specific index
    idea.resource :vote
  end

  map.resources :currents, :member => { :subscribe => :post, :unsubscribe => [:post, :get], :unfollow => :delete, :followers => :get } do |current|
    current.resources :ideas
  end
  map.resource :user, :member=>{:index=>:get}
  map.resource :session, :member => {
    :create_twitter => :get,
    :create_facebook => :get
  }
  map.resources :comments, :member => {:destroy_comment => :delete} # for global comment list
  map.resources :tags
  map.resources :profiles
  map.resource :map
map.resources :tests
  map.suggestions         '/suggestions',                        :controller => 'currents',  :action => 'show' , :id=> Current::SUGESSIONS_ID

  map.unfollow            '/users/unfollow/:id',                 :controller => 'users',    :action => 'unfollow'
  map.follow              '/users/follow/:id',                   :controller => 'users',    :action => 'follow'
  map.following           '/users/:id/following',                :controller => 'users',    :action => 'following'
  map.followers           '/users/:id/followers',                :controller => 'users',    :action => 'followers'
  map.login               '/login',                              :controller => 'sessions', :action => 'new'
  map.twitter_login       '/login/twitter',                      :controller => 'sessions', :action => 'new_twitter'
  map.logout              '/logout',                             :controller => 'sessions', :action => 'destroy'
  map.signup              '/signup',                             :controller => 'users', :action => 'new'
  map.idea_search         '/ideas/search/*search',               :controller => 'ideas', :action => 'index'
  map.idea_follow         '/ideas/follow',                    :controller => 'ideas', :action => 'follow', :conditions => {:method => :post}   
  #  map.idea_unfollow       '/ideas/unfollow', :controller => "ideas", :action => "unfollow", :conditions => {:method => :delete}
  #  map.idea_followers      '/ideas/followes', :controller => 'ideas', :action => 'followers', :conditions => {:method => :get}
  map.current_follow         '/currents/follow', :controller => 'currents', :action => 'follow', :conditions => {:method => :post}
  
  map.send_activation     '/user/send_activation',               :controller => 'users', :action => 'send_activation'
  map.activate            '/user/activate/:activation_code',     :controller => 'users', :action => 'activate'
  map.forgot_password     '/user/password/forgot',               :controller => 'users', :action => 'forgot_password',     :conditions => { :method => :get }
  map.send_password_reset '/user/password/forgot',               :controller => 'users', :action => 'send_password_reset', :conditions => { :method => :post }
  map.password_reset      '/user/password/new/:activation_code', :controller => 'users', :action => 'new_password'
  map.authorize_twitter   '/user/authorize/twitter',             :controller => 'users', :action => 'authorize_twitter'
  map.flag_inappropriate  '/:model/:id/inappropriate',           :controller => 'inappropriate', :action => 'flag'

  # Pretty URLS: these must come after more specific routes

  map.idea_pretty         '/ideas/:id/:title',                   :controller => 'ideas',    :action => 'show'
  map.profile_pretty      '/profiles/:id/:title',                :controller => 'profiles', :action => 'show'
  map.current_pretty      '/currents/:id/:title',                :controller => 'currents', :action => 'show'

  # OAuth stuff

  map.test_request '/oauth/test_request', :controller => 'oauth', :action => 'test_request'
  map.access_token '/oauth/access_token', :controller => 'oauth', :action => 'access_token'
  map.request_token '/oauth/request_token', :controller => 'oauth', :action => 'request_token'
  map.authorize '/oauth/authorize', :controller => 'oauth', :action => 'authorize'
  map.oauth '/oauth', :controller => 'oauth', :action => 'index'

  # Admin interface

  map.namespace :admin do |admin|
    admin.root :controller => 'home', :action => 'show'
    admin.resources :users, :member => { :suspend => :put, :unsuspend => :put, :activate => :put}, :collection =>{:search => :get, :search_name=> [:get,:post]}
    admin.resources :comments
    admin.resources :departments
    admin.resources :tags
    admin.resources :ideas
    admin.resources :currents
    admin.resources :client_applications
    admin.resource :chronology
    admin.with_options :path_prefix => 'admin/life_cycles', :controller => 'life_cycles' do |life_cycle|
      life_cycle.life_cycles 'edit',                 :action => 'edit'
      life_cycle.connect     'create',               :action => 'create'       # can't use post for these two b/c InPlaceEdtitor...
      life_cycle.connect     ':id/step/create',      :action => 'create_step'  # ...can't post when htmlResponse is false
      life_cycle.connect     ':id/update/order',     :action => 'reorder',                  :conditions => { :method => :post }
      life_cycle.connect     ':id/update/name',      :action => 'set_life_cycle_name',      :conditions => { :method => :post }
      life_cycle.connect     ':id/delete',           :action => 'delete',                   :conditions => { :method => :delete }
      life_cycle.connect     'step/:id/update/name', :action => 'set_life_cycle_step_name', :conditions => { :method => :post }
      life_cycle.connect     'step/:id/delete',      :action => 'delete_step',              :conditions => { :method => :delete }
    end
    admin.similar_ideas 'ideas/similar/:similar_to', :controller => 'ideas', :action => 'index'
    admin.similar_comments 'comments/similar/:similar_to', :controller => 'comments', :action => 'index'
    admin.with_options :path_prefix => 'admin/bucket', :controller => 'buckets', :name_prefix => 'admin_bucket_' do |bucket|
      bucket.show        '',                :action => 'show'
      bucket.add_idea    'add/:idea_id',    :action => 'add_idea',    :conditions => { :method => :put }
      bucket.remove_idea 'remove/:idea_id', :action => 'remove_idea', :conditions => { :method => :delete }
    end
    admin.with_options :controller => 'ideas' do |dup|
      dup.compare_duplicates 'ideas/:id/link_duplicate/:other_id', :action => 'compare_duplicates', :conditions => { :method => :get }
      dup.link_duplicates    'ideas/:id/link_duplicate/:other_id', :action => 'link_duplicates',    :conditions => { :method => :post }
    end
  end
  map.home_main_search '/home/main_search', :controller => "home", :action => "main_search", :conditions => {:method => [:get,:post]}
  # Top-level routes
  map.search_user '/users/search_user', :controller => 'users', :action => 'search_user', :conditions => {:method =>[:get,:post]}
  map.root :controller => 'home', :action => 'show'
  map.home_advance '/home/advance', :controller => 'home', :action => 'advance'
  map.home_nearby_ideas '/home/nearby-ideas', :controller => 'home', :action => 'nearby_ideas'
  map.current_ideas '/users/current_ideas', :controller => "users", :action => "current_ideas"
  map.current_currents '/users/current_currents', :controller => "users", :action => "current_currents"
  map.follow_users '/users/follow_users', :controller => "users", :action => "follow_users"
  map.home ':page', :controller => 'home', :action => 'show', :page => /about|contact|rules|privacy-policy|terms-of-use/
  map.profile_ideas '/profiles/current_ideas', :action => 'current_ideas', :controller => 'profiles'
  map.profile_currents '/profiles/current_currents', :action => 'current_currents', :controller => 'profiles'
  map.profile_followers '/profiles/followers', :action => 'my_followers', :controller => 'profiles'
  # No default routes declared for security & tidiness. (They make all actions in every controller accessible via GET requests.)
end
