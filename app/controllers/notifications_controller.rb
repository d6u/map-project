class NotificationsController < ApplicationController

  #     notifications GET    /notifications(.:format)           #index
  #                   POST   /notifications(.:format)           #create
  #  new_notification GET    /notifications/new(.:format)       #new
  # edit_notification GET    /notifications/:id/edit(.:format)  #edit
  #      notification GET    /notifications/:id(.:format)       #show
  #                   PATCH  /notifications/:id(.:format)       #update
  #                   PUT    /notifications/:id(.:format)       #update
  #                   DELETE /notifications/:id(.:format)       #destroy


  def index
    @notifications = []
    friend_requests = @user.followships.where('status = 0')
    @notifications += friend_requests
  end

end
