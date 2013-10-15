class Api::NoticesController < Api::ApiBaseController

  # GET    /api/notices                                #index
  # DELETE /api/notices/:id                            #destroy
  # POST   /api/notices/:id/accept_friend_request      #accept_friend_request
  # DELETE /api/notices/:id/ignore_friend_request      #ignore_friend_request
  # POST   /api/notices/:id/accept_project_invitation  #accept_project_invitation
  # DELETE /api/notices/:id/reject_project_invitation  #reject_project_invitation


  before_action :find_notice, except: [:index]


  # GET    /api/notices
  def index
    render json: @user.received_notices
  end


  # DELETE /api/notices/:id
  def destroy
    @notice.destroy
    render json: @notice
  end


  # POST   /api/notices/:id/accept_friend_request
  def accept_friend_request
    @notice.destroy

    friendship = Friendship.find_by_id @notice.content['fs_id']
    if friendship.nil?
      head 404
    elsif friendship.status != 0
      render :json => {:error      => true,
                       :message    => "Requested friendship is not a pending request, friendship status is '#{friendship.status}'",
                       :error_code => 'FS003'},
             :status => 400
    else
      # friendship exist and is a pending request
      friendship.update({status: 1})
      reverse_friendship = friendship.reverse_friendship
      @user.friendships << reverse_friendship

      render json: @notice

      notice = Notice.create_add_friend_request_accepted(@user, @notice.sender_id)
      send_push_notice(notice)
    end
  end


  # DELETE /api/notices/:id/ignore_friend_request
  def ignore_friend_request
    @notice.destroy
    render json: @notice
  end


  # POST   /api/notices/:id/accept_project_invitation
  def accept_project_invitation
    @notice.destroy
    render json: @notice

    participation = ProjectParticipation.find_by_id @notice.content['pp_id']
    project = participation.project

    project.project_participations.each {|pp|
      notice = Notice.create_new_user_added(project.owner_id, pp.user_id, project)
      send_push_notice(notice)
    }

    participation.update(status: 1)

    notice = Notice.create_project_invitation_accepted(@user, @notice.sender_id, project)
    send_push_notice(notice)
  end


  # DELETE /api/notices/:id/reject_project_invitation
  def reject_project_invitation
    @notice.destroy
    render json: @notice

    participation = ProjectParticipation.find_by_id(@notice.content[:pp_id])
    if participation
      participation.destroy

      notice = Notice.create_project_invitation_rejected(@user, @notice.sender_id, @notice.project_id)
      send_push_notice(notice)
    end
  end


  # --- Private ---

  def find_notice
    @notice = Notice.find(params[:id])
  end

  private :find_notice

end
