class ProjectsController < ApplicationController

  #     projects GET    /projects(.:format)          projects#index
  #              POST   /projects(.:format)          projects#create
  #  new_project GET    /projects/new(.:format)      projects#new
  # edit_project GET    /projects/:id/edit(.:format) projects#edit
  #      project GET    /projects/:id(.:format)      projects#show
  #              PATCH  /projects/:id(.:format)      projects#update
  #              PUT    /projects/:id(.:format)      projects#update
  #              DELETE /projects/:id(.:format)      projects#destroy


  def index
    if params[:title]
      project = @user.projects.find_by_title params[:title]
      if project
        render :json => project
      else
        head 404
      end
    else
      projects = @user.projects.order 'created_at DESC'
      render :json => projects
    end
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
    head 200
  end

end
