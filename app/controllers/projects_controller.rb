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
    projects = @user.projects
    render :json => projects
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

end
