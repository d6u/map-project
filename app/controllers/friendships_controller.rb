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
  # ----------------------------------------
  def create
    friendship = @user.friendships.find_by_friend_id params[:friendship][:friend_id]

    # --- Friendship record already exist ---
    if friendship
      # user blocked friend
      if friendship.status < 0
        render :json => {:error      => true,
                         :message    => 'You have blocked this user.',
                         :error_code => 'FS000'},
               :status => 409
      # request already sent
      elsif friendship.status == 0
        render :json => {:error      => true,
                         :message    => 'Friend request has already sent.',
                         :error_code => 'FS001'},
               :status => 409
      # already friends
      else
        render :json => {:error      => true,
                         :message    => 'You are already friends',
                         :error_code => 'FS002'},
               :status => 409
      end

    # --- Brand new friendship ---
    else
      friendship = Friendship.new params.require(:friendship).permit(:friend_id, :comments)
      @user.friendships << friendship

      # Create notice object and send to Node.js server
      add_friend_request = Notice.create({
        :type     => 'addFriendRequest',
        :sender   => @user.public_info,
        :receiver => friendship.friend_id,
        :body     => { friendship_id: friendship.id }
      })

      $redis.publish 'notice_channel', add_friend_request.to_json
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

  end


  # DELETE
  def destroy
    Friendship.destroy_all :id => params[:id]
    head 200
  end


  # POST /api/friendships/:id/accept_friend_request
  # ----------------------------------------
  def accept_friend_request
    Notice.destroy_all({:id => params[:notice_id]})
    friendship = Friendship.find_by_id(params[:id])
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
        :receiver => friendship.friend_id,
        :body     => { friendship_id: friendship.id }
      })

      $redis.publish 'notice_channel', add_friend_request_accepted.to_json
      render :json => reverse_friendship
    end
  end

end
