class UsersController < ApplicationController

  # POST   /api/users/fb_login        fb_login
  # POST   /api/users/fb_register     fb_register
  # POST   /api/users/email_login     email_login
  # POST   /api/users/email_register  email_register
  # GET    /api/users/logout          logout
  # GET    /api/users                 index
  # PATCH  /api/users/:id             update
  # PUT    /api/users/:id             update


  skip_before_action :check_login_status,
                     :only => [:fb_login, :fb_register, :email_login,
                               :email_register]


  # POST   /api/users/fb_login        fb_login
  # ----------------------------------------
  def fb_login
    user = User.find_by_fb_user_id(params[:user][:fb_user_id])
    head 404 and return if !user

    user.fb_access_token = params[:user][:fb_access_token] if user.fb_access_token.to_s === params[:user][:fb_access_token]

    if user.validate_with_facebook
      user.save if user.changed?
      session[:user_id] = user.id
      render :json => user
    else
      head 401
    end
  end


  # POST   /api/users/fb_register     fb_register
  # ----------------------------------------
  def fb_register
    user = User.new params.require(:user).permit(:fb_access_token, :fb_user_id, :name, :email, :profile_picture)

    if user.validate_with_facebook
      user.save
      session[:user_id] = user.id
      render :json => user
    else
      head 406
    end
  end


  # POST   /api/users/email_login     email_login
  # ----------------------------------------
  def email_login
    user = User.authorize_with_email(params[:user])
    if user
      session[:user_id] = user.id
      render json: user,
             except: [:password_salt, :password_hash, :fb_access_token]
    else
      head 401
    end
  end


  # POST   /api/users/email_register  email_register
  # ----------------------------------------
  def email_register
    if params[:user][:password] != params[:user][:password_confirmation]
      render json: {error:    true,
                    message: 'Password and password confirmation does not match.',
                    error_code: 'US000'},
             status: 406
    else
      user = User.create params.require(:user).permit(:name, :email, :password)
      render json: user,
             except: [:password_salt, :password_hash, :fb_access_token]
    end
  end


  ##
  # Logout
  # ----------------------------------------
  def logout
    if session[:user_id]
      session[:user_id] = nil
      # return empty JSON array to fix restangular .addRestangularMethod no
      #   method error
      render :json => [], :status => 202
    else
      # return empty JSON array to fix restangular .addRestangularMethod no
      #   method error
      render :json => [], :status => 200
    end
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
        render :json => users, :only => [:id, :name, :fb_user_picture] and return
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
      @user.attributes = params.require(:user).permit(:fb_access_token, :fb_user_id, :name, :email, :fb_user_picture)
      @user.save if @user.changed?
      render :json => @user
    else
      head 401
    end
  end

end
