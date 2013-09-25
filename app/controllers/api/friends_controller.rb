module Api

class FriendsController < ApplicationController

  #     friends GET    /friends(.:format)           friends#index
  #             POST   /friends(.:format)           friends#create
  #  new_friend GET    /friends/new(.:format)       friends#new
  # edit_friend GET    /friends/:id/edit(.:format)  friends#edit
  #      friend GET    /friends/:id(.:format)       friends#show
  #             PATCH  /friends/:id(.:format)       friends#update
  #             PUT    /friends/:id(.:format)       friends#update
  #             DELETE /friends/:id(.:format)       friends#destroy


  def index
    render :json => @user.friends, :only => [:id, :name, :profile_picture]
  end


  def show
    friend = @user.friends.find_by_id params[:id]
    if friend
      render :json => friend, :only => [:id, :name, :profile_picture]
    else
      head 404
    end
  end

end

end
