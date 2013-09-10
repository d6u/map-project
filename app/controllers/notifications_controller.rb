class NotificationsController < ApplicationController

  # GET     /api/notifications                            #index
  # DELETE  /api/notifications/:id                        #destroy
  # POST    /api/notifications/:id/accept_friend_request  #accept_friend_request
  # DELETE  /api/notifications/:id/ignore_friend_request  #ignore_friend_request


  # GET     /api/notifications
  # ----------------------------------------
  def index
    notifications         = Notice.where({receiver: @user.id})
    projectIds            = @user.projects.pluck :id
    project_notifications = Notice.in(:project => projectIds)
    render json: (notifications + project_notifications)
  end


  # DELETE  /api/notifications/:id
  # ----------------------------------------
  def destroy
    Notice.find(params[:id]).destroy
    head 200
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
        :type     => 'addFriendRequestAccepted',
        :sender   => @user.public_info,
        :receiver => reverse_friendship.friend_id,
        :body     => { friendship_id: friendship.id }
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

end
