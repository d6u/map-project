class NotificationsController < ApplicationController

  #     notifications GET    /notifications(.:format)           #index
  #                   POST   /notifications(.:format)           #create
  #  new_notification GET    /notifications/new(.:format)       #new
  # edit_notification GET    /notifications/:id/edit(.:format)  #edit
  #      notification GET    /notifications/:id(.:format)       #show
  #                   PATCH  /notifications/:id(.:format)       #update
  #                   PUT    /notifications/:id(.:format)       #update
  #                   DELETE /notifications/:id(.:format)       #destroy


  # GET
  # ----------------------------------------
  def index
    notifications         = Notice.where({receiver: @user.id})
    projectIds            = @user.projects.pluck :id
    project_notifications = Notice.in(:project => projectIds)
    render json: (notifications + project_notifications)
  end


  # DELETE /api/notifications/:id
  # ----------------------------------------
  def destroy
    Notice.find(params[:id]).destroy
    head 200
  end


  # DELETE /api/notifications/:id/ignore_friend_request
  # ----------------------------------------
  def ignore_friend_request
    notice = Notice.find(params[:id])
    if notice
      Friendship.destroy_all(:id => notice['body']['friendship_id'])
      notice.destroy
      head 200
    else
      head 404
    end
  end

end
