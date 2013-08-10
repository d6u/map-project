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
    render :json => @user.friends, :only => [:id, :name, :fb_user_picture]
  end


  def create
    friendship = Friendship.new params.require(:friendship).permit(:friend_id, :status, :comments)
    @user.friendships << friendship
    render :json => friendship
  end


  def show
    friendship = Friendship.find_by_id params[:id]
    if friendship
      render :json => friendship
    else
      head 404
    end
  end


  def update
    friendship = Friendship.find_by_id params[:id]
    if friendship
      friendship.attributes = params.require(:friendship).permit(:status, :comments)
      friendship.save if friendship.changed?
      render :json => friendship
    else
      head 404
    end
  end


  def destroy
    Friendship.destroy_all :id => params[:id]
    head 200
  end

end
