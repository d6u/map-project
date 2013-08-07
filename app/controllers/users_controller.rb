class UsersController < ApplicationController

  #     users GET    /users(.:format)          users#index
  #           POST   /users(.:format)          users#create
  #  new_user GET    /users/new(.:format)      users#new
  # edit_user GET    /users/:id/edit(.:format) users#edit
  #      user GET    /users/:id(.:format)      users#show
  #           PATCH  /users/:id(.:format)      users#update
  #           PUT    /users/:id(.:format)      users#update
  #           DELETE /users/:id(.:format)      users#destroy


  skip_before_action :check_login_status, :only => [:login, :logout, :create]


  ##
  # Login in with fb user data
  # ----------------------------------------
  def login
    unless user = User.find_by_fb_user_id(params[:user][:fb_user_id])
      # user not found
      head 404 and return
    end

    # TODO: fix always update access_token
    user.fb_access_token = params[:user][:fb_access_token]

    if user.validate_with_facebook
      user.save if user.changed?
      session[:user_id] = user.id
      render :json => user, :status => 200
    else
      head 401
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


  ##
  # register
  # ----------------------------------------
  def create
    user = User.new params.require(:user).permit(:fb_access_token, :fb_user_id, :name, :email, :fb_user_picture)

    if user.validate_with_facebook
      user.save
      session[:user_id] = user.id
      render :json => user
    else
      head 406
    end
  end


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
