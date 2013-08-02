class UsersController < ApplicationController

  #     users GET    /users(.:format)          users#index
  #           POST   /users(.:format)          users#create
  #  new_user GET    /users/new(.:format)      users#new
  # edit_user GET    /users/:id/edit(.:format) users#edit
  #      user GET    /users/:id(.:format)      users#show
  #           PATCH  /users/:id(.:format)      users#update
  #           PUT    /users/:id(.:format)      users#update
  #           DELETE /users/:id(.:format)      users#destroy


  skip_before_action :check_login_status, :only => [:login, :register, :logout]


  ##
  # Login in with fb user data
  # ----------------------------------------
  def login
    head 404 unless user = User.find_by_fb_user_id(params[:user][:fb_user_id])

    # TODO: fix always update access_token
    user.fb_access_token = params[:user][:fb_access_token]
    if user.validate_with_facebook
      user.save if user.changed?
      session[:user_id] = user.id
      render :json => user, :status => 200
    else
      head 406
    end
  end


  ##
  def register
    user = User.new params.require(:user).permit(:fb_access_token, :fb_user_id, :name, :email)
    if user.validate_with_facebook
      user.save if user.changed?
      session[:user_id] = user.id
      render :json => user, :status => 200
    else
      head 406
    end
  end


  ##
  # Logout
  # ----------------------------------------
  def logout
    session[:user_id] = nil if session[:user_id]
    head 200
  end

end
