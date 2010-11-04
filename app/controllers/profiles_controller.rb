class ProfilesController < ApplicationController
  
  def show
    @body_class = 'profile'
    @user = User.find(params[:id])
    
    if @user.active? || @user == current_user
      respond_to do |format|
        format.html
        format.xml
      end
    else
      resource_gone
    end
  end
  
  def page_title
    "User Profile: #{@user.name}" if @user
  end
    
end
