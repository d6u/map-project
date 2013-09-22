class ProjectsController < ApplicationController

  # GET     /api/projects/:project_id/participating_users  participating_users
  # POST    /api/projects/:project_id/add_users            add_users
  # DELETE  /api/projects/:project_id/remove_users         remove_users
  # GET     /api/projects                                  index
  # POST    /api/projects                                  create
  # GET     /api/projects/:id                              show
  # PATCH   /api/projects/:id                              update
  # PUT     /api/projects/:id                              update
  # DELETE  /api/projects/:id                              destroy


  # GET     /api/projects/:project_id/participating_users
  def participating_users
    project = Project.find_by_id(params[:project_id])
    if project
      if @user == project.owner
        render(json: project.participating_users,
               only: [:id, :name, :profile_picture])
      else
        render(json: (project.participating_users - [@user] + [project.owner]),
               only: [:id, :name, :profile_picture])
      end
    else
      head(404)
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
    @projects = params[:include_participating] == 'true' ? @user.projects + @user.participating_projects : @user.projects
  end


  # POST    /api/projects
  def create
    @project = Project.new(params.require(:project).permit(:title, :notes))
    @user.projects << @project
  end







  def show
    project = params[:title] ? @user.projects.find_by_title(params[:title]) : @user.projects.find_by_id(params[:id])

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
