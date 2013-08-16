class ProjectsController < ApplicationController

  #     projects GET    /projects(.:format)          projects#index
  #              POST   /projects(.:format)          projects#create
  #  new_project GET    /projects/new(.:format)      projects#new
  # edit_project GET    /projects/:id/edit(.:format) projects#edit
  #      project GET    /projects/:id(.:format)      projects#show
  #              PATCH  /projects/:id(.:format)      projects#update
  #              PUT    /projects/:id(.:format)      projects#update
  #              DELETE /projects/:id(.:format)      projects#destroy


  # POST /projects/:project_id/users
  def add_user
    user_ids = params[:user_ids].split(',')
    project  = Project.find_by_id params[:project_id]
    project.participated_users.each {|user|
      project.participated_users.delete(user) if !(user_ids.include? user.id.to_s)
    }
    users = user_ids.map {|id|
      user = User.find_by_id id
      begin
        project.participated_users << user
      rescue ActiveRecord::RecordNotUnique
        # do thing
      end
      user
    }
    render :json => project.participated_users, :only => [:id, :name, :fb_user_picture]
  end


  # GET
  def index
    if params[:title]
      project = @user.projects.find_by_title params[:title]
      if project
        render :json => project and return
      else
        head 404 and return
      end
    end


    if params[:include_participated] == 'true'
      user_projects = @user.projects
      participated_projects = @user.participated_projects
      projects = user_projects + participated_projects
      projects.sort! {|a,b| b.updated_at <=> a.updated_at}
    else
      projects = @user.projects.order 'updated_at DESC'
    end
    render :json => projects, :methods => :places_attrs
  end


  def create
    project = Project.new params.require(:project).permit(:title, :notes)
    @user.projects << project
    render :json => project
  end


  def show
    project = Project.find_by_id params[:id]
    if project
      render :json => project
    else
      head 401
    end
  end


  def update
    project = Project.find_by_id params[:id]
    project.attributes = params.require(:project).permit(:title, :notes)
    project.save if project.changed?
    render :json => project
  end


  def destroy
    Project.destroy_all :id => params[:id]
    render :json => []
  end

end
