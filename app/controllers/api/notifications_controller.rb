class Api::NotificationsController < Api::ApiBaseController

  # GET     /api/notifications                            #index
  # DELETE  /api/notifications/:id                        #destroy
  # POST    /api/notifications/:id/accept_friend_request  #accept_friend_request
  # DELETE  /api/notifications/:id/ignore_friend_request  #ignore_friend_request
  # POST    /api/notifications/:id/accept_project_invitation  #accept_project_invitation
  # DELETE  /api/notifications/:id/reject_project_invitation  #reject_project_invitation


  # GET     /api/notifications
  # ----------------------------------------
  def index
    render json: Notice.where({receiver_id: @user.id})
  end


  # DELETE  /api/notifications/:id
  # ----------------------------------------
  def destroy
    notice = Notice.find(params[:id])
    if notice
      notice.destroy
      head 200
    else
      head 404
    end
  end


  # POST    /api/notifications/:id/accept_friend_request
  # ----------------------------------------
  def accept_friend_request
    Notice.destroy_all(:id => params[:id])
    friendship = Friendship.find_by_id(params[:friendship_id])
    if !friendship
      head 404
    elsif friendship.status != 0
      render :json => {:error      => true,
                       :message    => "Requested friendship is not a pending request, friendship status is #{friendship.status}",
                       :error_code => 'FS003'},
             :status => 400
    else
      # friendship exist and is a pending request
      friendship.update({status: 1})
      reverse_friendship = friendship.reverse_friendship
      @user.friendships << reverse_friendship

      # Create notice object and send to Node.js server
      add_friend_request_accepted = Notice.create({
        :type        => 'addFriendRequestAccepted',
        :sender      => @user.public_info,
        :receiver_id => reverse_friendship.friend_id,
        :body        => { friendship_id: friendship.id }
      })

      $redis.publish 'notice_channel', add_friend_request_accepted.to_json
      render :json => reverse_friendship
    end
  end


  # DELETE  /api/notifications/:id/ignore_friend_request
  # ----------------------------------------
  def ignore_friend_request
    Notice.destroy_all(:id => params[:id])
    Friendship.destroy_all(:id => params['friendship_id'])
    head 200
  end


  # POST    /api/notifications/:id/accept_project_invitation
  # ----------------------------------------
  def accept_project_invitation
    pp      = ProjectParticipation.find_by_id params[:project_participation_id]
    project = pp.project
    # send current participating users notice
    project.participating_users.each do |pu|
      new_user_added = Notice.create({
        type:        'newUserAdded',
        sender:      @user.public_info,
        receiver_id: pu.id,
        body: {
          new_user: @user.public_info,
          project: {
            id:    project.id,
            title: project.title,
            notes: project.notes
          }
        }
      })
      $redis.publish 'notice_channel', new_user_added.to_json
    end

    pp.update(status: 1)
    pia = Notice.create({
      type:        'projectInvitationAccepted',
      sender:      @user.public_info,
      receiver_id: project.owner_id,
      body: {
        project_participation_id: pp.id,
        project: {
          id:    project.id,
          title: project.title,
          notes: project.notes
        }
      }
    })
    Notice.find(params[:id]).destroy
    $redis.publish 'notice_channel', pia.to_json

    head 200
  end


  # DELETE  /api/notifications/:id/reject_project_invitation
  # ----------------------------------------
  def reject_project_invitation
    ProjectParticipation.destroy_all(id: params[:project_participation_id])
    project_invitation = Notice.find(params[:id])
    project_invitation_rejected = Notice.create({
      type:        'projectInvitationRejected',
      sender:      @user.public_info,
      receiver_id: project_invitation['sender']['id'],
      body: {
        project: {
          id:    project_invitation['body']['project']['id'],
          title: project_invitation['body']['project']['title'],
          notes: project_invitation['body']['project']['notes']
        }
      }
    })
    project_invitation.destroy
    $redis.publish 'notice_channel', project_invitation_rejected.to_json
    head 200
  end

end
