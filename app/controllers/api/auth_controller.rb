class Api::AuthController < Api::ApiBaseController

  skip_before_action :check_login_status
  skip_before_action :find_user



  def login_status
    # session exist
    if !session[:user_id].nil?
      if !( user = User.find_by_id(session[:user_id]) ).nil?
        render json: user, only: [:id, :name, :profile_picture, :email]
        return
      else
        session[:user_id] = nil
      end
    end

    # remember me cookie
    if cookies[:user_token] && cookies[:user_id]
      remember_login = RememberLogin.where({
        remember_token: cookies[:user_token],
        user_id:        cookies[:user_id]
      }).first
      if remember_login
        if remember_login.login_type == 0 # email
          user = remember_login.user
          session[:user_id] = user.id
          remember_login.destroy
          remember_user_on_this_computer(user, 0)
          render json: user, only: [:id, :name, :profile_picture, :email]
        elsif remember_login.login_type == 1 # facebook
          render json: {remember_login: true, type: 'facebook'}
        end
        return
      # remember token is invalid
      else
        cookies.delete :user_token, :domain => :all
        cookies.delete :user_id   , :domain => :all
      end
    end

    # remove incomplete cookie pair
    if cookies[:user_token] || cookies[:user_id]
      cookies.delete :user_token, :domain => :all
      cookies.delete :user_id   , :domain => :all
    end

    head 404
  end


  # --- Private ---

  def remember_user_on_this_computer(user, login_type)
    new_remember_login = RememberLogin.new(login_type: type)
    user.remember_logins << new_remember_login
    cookies[:user_token] = {
      value:   new_remember_login.remember_token,
      domain:  '.' + request.domain,
      expires: 3.month.from_now
    }
    cookies[:user_id] = {
      value:   user.id,
      domain:  '.' + request.domain,
      expires: 3.month.from_now
    }
    return new_remember_login
  end

  private :remember_user_on_this_computer

end
