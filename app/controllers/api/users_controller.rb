class Api::UsersController < Api::ApiBaseController

  # POST   /api/users/email_login     email_login
  # POST   /api/users/email_register  email_register
  # GET    /api/users/logout          logout
  # GET    /api/users                 index
  # PATCH  /api/users/:id             update
  # PUT    /api/users/:id             update


  skip_before_action :check_login_status, :only => [:login_status, :fb_login, :fb_register, :email_login, :email_register, :logout]


  # POST   /api/users/email_login     email_login
  # ----------------------------------------
  def email_login
    @user = User.authorize_with_email(params[:email], params[:password])
    if @user
      session[:user_id] = @user.id
      remember_user_on_this_computer if params[:remember_me]
      render json: @user,
             except: [:password_salt, :password_hash, :fb_access_token]
    else
      head 401
    end
  end


  # POST   /api/users/email_register  email_register
  # ----------------------------------------
  def email_register
    if params[:password] != params[:password_confirmation]
      render json: {error:    true,
                    message: 'Password and password confirmation does not match.',
                    error_code: 'US000'},
             status: 406
    else
      @user = User.create params.permit(:name, :email, :password)
      session[:user_id] = @user.id
      remember_user_on_this_computer
      render json: @user,
             except: [:password_salt, :password_hash, :fb_access_token]
    end
  end


  # GET    /api/users/logout          logout
  # ----------------------------------------
  def logout
    if @user
      if cookies[:user_token]
        RememberLogin.destroy_all({
          user_id:        @user.id,
          remember_token: cookies[:user_token]
        })
      end

      session[:user_id] = nil
      cookies.delete :user_token, :domain => :all
      cookies.delete :user_id   , :domain => :all
    end
    head 200
  end


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
