module Admin
  class DepartmentsController < AdminController
    before_filter :set_body_class
    make_resourceful do
      actions :index, :new, :create,:edit, :update

      before :new do
        render :action=>"edit"
      end
      response_for :index do |format|
        format.html { render :action => 'index' }
        format.js   { render :partial => 'index' }
      end



      response_for :update do |format|
        format.html do
          flash[:info] = 'Changes saved.'
          redirect_to edit_admin_department_path(@department)
        end
        format.js do
          render :text => 'OK'
        end
      end
    end

    include ResourceAdmin

  protected

    def default_sort
      if search_pending_moderation?
        ['inappropriate_flags', true]
      else
        ['created_at', true]
      end
    end

    def set_body_class
      @body_class = 'comments'
    end
  end
end
