class Api::UsersController < Api::ApiBaseController

  # GET  /api/users
  #   search user by name
  def index
    if params[:name]
      name   = "%#{params[:name]}%"
      @users = User.where('lower(name) LIKE lower(?) AND id <> ?', name, @user.id)
      @added_friends_id   = @user.friendships.pluck(:friend_id)
      @pending_friends_id = @user.friendships.where('status = 0').pluck(:friend_id)
      render 'query_user' and return
    end
    head 401
  end


  # GET  /api/users/:id
  def show
    @user = User.find_by_id(params[:id])
    if @user.nil?
      head 404
    else
      render json: @user, only: [:id, :name, :profile_picture]
    end
  end

end
