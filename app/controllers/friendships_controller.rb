class FriendshipsController < ApplicationController

  #     friendships GET    /friendships(.:format)            #index
  #                 POST   /friendships(.:format)            #create
  #  new_friendship GET    /friendships/new(.:format)        #new
  # edit_friendship GET    /friendships/:id/edit(.:format)   #edit
  #      friendship GET    /friendships/:id(.:format)        #show
  #                 PATCH  /friendships/:id(.:format)        #update
  #                 PUT    /friendships/:id(.:format)        #update
  #                 DELETE /friendships/:id(.:format)        #destroy


  def index
    render :json => @user.friendships.order('status DESC'), :include => :friend
  end


  def create
    friendship = @user.friendships.find_by_friend_id params[:friendship][:friend_id]
    if friendship
      head 200 and return if friendship.status > 0
      friendship.status = 0
      friendship.save
    else
      friendship = Friendship.new params.require(:friendship).permit(:friend_id, :status, :comments)
      @user.friendships << friendship
    end

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
      @user.friendships << friendship.reverse_friendship
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
