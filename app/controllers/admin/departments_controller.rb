module Admin
  class DepartmentsController < AdminController
    before_filter :set_body_class
    make_resourceful do
      actions :index, :new, :create,:edit, :update

      response_for :index do |format|
        format.html { render :action => 'index' }
        format.js   { render :partial => 'index' }
      end


      response_for :create do |format|
        format.html do
          flash[:info]="Department created"
          redirect_to admin_departments_path
        end
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
        ['departments.created_at', true]
    end

    def set_body_class
      @body_class = 'comments'
    end
  end
end
