class UsersController < ApplicationController

  #     users GET    /users(.:format)          users#index
  #           POST   /users(.:format)          users#create
  #  new_user GET    /users/new(.:format)      users#new
  # edit_user GET    /users/:id/edit(.:format) users#edit
  #      user GET    /users/:id(.:format)      users#show
  #           PATCH  /users/:id(.:format)      users#update
  #           PUT    /users/:id(.:format)      users#update
  #           DELETE /users/:id(.:format)      users#destroy


  skip_before_action :check_login_status, :only => [:login]


  ##
  # Login in with fb user data
  # ----------------------------------------
  def login
    if params[:user]
      user = User.find_by_fb_user_id(params[:user][:fb_user_id]) || User.new(params.require(:user).permit(:email, :fb_access_token, :fb_user_id, :name))
    else
      redirect_to :root
    end

    # TODO: fix always update access_token
    user.attributes = params.require(:user).permit(:email, :fb_access_token, :fb_user_id, :name)
    if user.validate_with_facebook
      user.save if user.changed?
      session[:user_id] = user.id
      render :json => user, :status => 200
    else
      head 406
    end
  end

end
