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
  # ----------------------------------------
  def add_users
    user_ids = params[:user_ids].split(',')
    project  = Project.find_by_id params[:project_id]
    head 404 and return if !project
    project_participations = user_ids.map do |id|
      {:project_id => project.id,
       :user_id    => id,
       :status     => 0}
    end
    begin
      participations = ProjectParticipation.create(project_participations)
    rescue ActiveRecord::RecordNotUnique
      head 409 and return
    end

    # send notice to each user
    participations.each do |participation|
      project_invitation = Notice.create({
        type:        'projectInvitation',
        sender:      @user.public_info,
        receiver_id: participation.user_id,
        body: {
          project_participation_id: participation.id,
          project: {
            id:    project.id,
            title: project.title,
            notes: project.notes
          }
        }
      })
      $redis.publish 'notice_channel', project_invitation.to_json
    end

    head 200
  end


  # DELETE  /api/projects/:project_id/remove_users
  # ----------------------------------------
  def remove_users
    project  = Project.find_by_id params[:project_id]
    head 404 and return if !project

    removing_ids = params[:user_ids].split(',')
    project.project_participations.each do |pp|
      if removing_ids.include? pp.user_id
        pp.destroy
        you_are_removed_from_project = Notice.create({
          type:       'youAreRemovedFromProject',
          sender:      @user.public_info,
          receiver_id: pp.user_id,
          body: {
            project: {
              title: project.title
            }
          }
        })
        $redis.publish 'notice_channel', you_are_removed_from_project.to_json
      else
        project_user_list_updated = Notice.create({
          type:       'projectUserListUpated',
          sender:      @user.public_info,
          receiver_id: pp.user_id,
          body: {
            project: {
              id:    project.id,
              title: project.title
            }
          }
        })
        $redis.publish 'notice_channel', project_user_list_updated.to_json
      end
    end

    head 200
  end


  # GET     /api/projects
  def index
    if params[:include_participating] == true
      @projects = @user.projects + @user.participating_projects
    else
      @projects = @user.projects
    end
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
