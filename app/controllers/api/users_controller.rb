class Api::UsersController < Api::ApiBaseController

  # GET    /api/users                 index
  # PATCH  /api/users/:id             update
  # PUT    /api/users/:id             update


  # GET /projects/:project_id/users
  #   get paricipated_users for, return results include project owner
  # GET /users
  #   search users by name
  def index
    # get paricipated_users for
    if params[:project_id]
      project = Project.find_by_id(params[:project_id])
      if project
        users = project.participated_users
        render :json => users, :only => [:id, :name, :profile_picture] and return
      else
        head 404 and return
      end
    end

    # search users by name
    if params[:name]
      name   = "%#{params[:name]}%"
      @users = User.where('lower(name) LIKE lower(?) AND id <> ?', name, @user.id)
      @added_friends_id   = @user.friendships.pluck(:friend_id)
      @pending_friends_id = @user.friendships.where('status = 0').pluck(:friend_id)
      render 'query_user' and return
    end

    head 401
  end


  # PUT & PATCH /users/:id
  def update
    if @user.id == params[:user][:id]
      @user.attributes = params.require(:user).permit(:fb_access_token, :fb_user_id, :name, :email, :profile_picture)
      @user.save if @user.changed?
      render :json => @user
    else
      head 401
    end
  end

end
