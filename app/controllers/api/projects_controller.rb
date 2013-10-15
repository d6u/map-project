class Api::ProjectsController < Api::ApiBaseController

  # GET     /api/projects/:project_id/participating_users  participating_users
  # POST    /api/projects/:project_id/add_users            add_users
  # DELETE  /api/projects/:project_id/remove_users         remove_users
  # GET     /api/projects                                  index
  # POST    /api/projects                                  create
  # GET     /api/projects/:id                              show
  # PATCH   /api/projects/:id                              update
  # PUT     /api/projects/:id                              update
  # DELETE  /api/projects/:id                              destroy


  before_action :find_project_if_authorized_to_view


  # GET     /api/projects/:project_id/participating_users
  def participating_users
    if @project.owner == @user
      render(json: @project.participating_users,
             only: [:id, :name, :profile_picture])
    else
      render(json: (@project.participating_users - [@user] + [@project.owner]),
             only: [:id, :name, :profile_picture])
    end
  end


  # POST    /api/projects/:project_id/add_users
  def add_users
    user_ids = params[:user_ids].split(',').map {|id| id.to_i}

    project_participations = []

    user_ids.each {|id|
      participation = ProjectParticipation.new({
        project_id: @project.id,
        user_id:    id
      })
      if @project.project_participations << participation
        project_participations << participation
        notice = Notice.create_project_invitation(@user, id, @project, participation)
        send_push_notice(notice)
      end
    }

    render json: project_participations
  end


  # DELETE  /api/projects/:project_id/remove_users
  def remove_users
    removing_ids = params[:user_ids].split(',').map {|id| id.to_i}

    destroyed_participations = []

    @project.project_participations.each {|pp|
      if removing_ids.include? pp.user_id
        pp.destroy
        destroyed_participations << pp

        notice = Notice.create_your_are_removed_from_project(@user, pp.user_id, @project)
        send_push_notice(notice)
      end
    }

    render json: destroyed_participations

    @project.reload
    @project.participating_users.each {|pu|
      notice = Notice.create_project_user_list_updated(@user, pu, @project)
      send_push_notice(notice)
    }
  end


  # GET     /api/projects
  def index
    @projects = @user.projects + @user.participating_projects
  end


  # POST    /api/projects
  def create
    @project = Project.new(params.require(:project).permit(:title, :notes))
    @user.projects << @project
  end


  # GET     /api/projects/:id
  def show
    render json: @project
  end


  # PATCH   /api/projects/:id
  # PUT     /api/projects/:id
  def update
    @project.attributes = params.require(:project).permit(:title, :notes)
    @project.save if @project.changed?
    render json: @project
  end


  # DELETE  /api/projects/:id
  def destroy
    @project.destroy
    render json: @project
  end


  # --- Private ---

  def find_project_if_authorized_to_view
    id = params[:id] || params[:project_id]
    if !id.nil?
      @project = Project.find_by_id(id)

      if @project.nil? || (@project.owner != @user && !@user.participating_projects.include?(@project))
        head 401
      end
    end
  end

  private :find_project_if_authorized_to_view

end
