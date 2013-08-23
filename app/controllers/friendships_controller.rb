class FriendshipsController < ApplicationController

  #     friendships GET    /friendships(.:format)            #index
  #                 POST   /friendships(.:format)            #create
  #  new_friendship GET    /friendships/new(.:format)        #new
  # edit_friendship GET    /friendships/:id/edit(.:format)   #edit
  #      friendship GET    /friendships/:id(.:format)        #show
  #                 PATCH  /friendships/:id(.:format)        #update
  #                 PUT    /friendships/:id(.:format)        #update
  #                 DELETE /friendships/:id(.:format)        #destroy


  # GET
  def index
    render :json => @user.friendships.order('status DESC'), :include => :friend
  end


  # POST
  def create
    friendship = @user.friendships.find_by_friend_id params[:friendship][:friend_id]
    if friendship
      # including blocked situation
      if friendship.status <= 0
        render :json => {:error   => true,
                         :message => 'Friend request has already sent.'},
               :status => 409
      elsif friendship.status > 0
        render :json => {:error   => true,
                         :message => 'You are already friends'},
               :status => 409
      end
    else
      friendship = Friendship.new params.require(:friendship).permit(:friend_id, :status, :comments)
      @user.friendships << friendship
      render :json => friendship
    end
  end


  # GET
  def show
    friendship = Friendship.find_by_id params[:id]
    if friendship
      render :json => friendship
    else
      head 404
    end
  end


  # PUT
  def update
    friendship = Friendship.find_by_id params[:id]
    if friendship
      friendship.attributes = params.require(:friendship).permit(:status, :comments)
      friendship.save if friendship.changed?
      if friendship.status > 0
        reverse_friendship = @user.friendships.find_by_friend_id friendship.user_id
        if reverse_friendship
          render :json => {:error   => true,
                           :message => 'You are already friends'},
                 :status => 409
        else
          reverse_friendship = friendship.reverse_friendship
          @user.friendships << reverse_friendship
          render :json => reverse_friendship.friend
        end
      end
    else
      head 404
    end
  end


  # DELETE
  def destroy
    Friendship.destroy_all :id => params[:id]
    head 200
  end

end
