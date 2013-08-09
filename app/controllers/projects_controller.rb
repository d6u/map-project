class ProjectsController < ApplicationController

  #     projects GET    /projects(.:format)          projects#index
  #              POST   /projects(.:format)          projects#create
  #  new_project GET    /projects/new(.:format)      projects#new
  # edit_project GET    /projects/:id/edit(.:format) projects#edit
  #      project GET    /projects/:id(.:format)      projects#show
  #              PATCH  /projects/:id(.:format)      projects#update
  #              PUT    /projects/:id(.:format)      projects#update
  #              DELETE /projects/:id(.:format)      projects#destroy


  # POST
  def add_participated_user
    project = Project.find_by_id params[:project_id]
    target_user = User.find_by_id params[:id]

    project.participated_users << target_user
    render :json => []
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
    render :json => project
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
