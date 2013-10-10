class Api::AuthController < Api::ApiBaseController

  skip_before_action :check_login_status, except: [:logout]
  skip_before_action :find_user         , except: [:logout]



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



  def fb_register
    @user = User.new params.require(:user).permit(:fb_access_token, :fb_user_id, :name, :email, :profile_picture)

    if fb_access_token = @user.fb_exchange_long_lived_token
      @user.fb_access_token = fb_access_token
      @user.save
      session[:user_id] = @user.id
      remember_user_on_this_computer(@user, 1)

      @code = @user.fb_exchange_token_code
      render 'fb_authorize'
    else
      head 406 # not acceptable
    end
  end



  def fb_login
    user_params = params.require(:user).permit!

    if ( @user = User.find_by_fb_user_id(user_params[:fb_user_id]) ).nil?
      head 406 # not acceptable
    else
      if fb_access_token = @user.fb_exchange_long_lived_token(user_params[:fb_access_token])
        @user.fb_access_token = fb_access_token
        @user.save
        session[:user_id] = @user.id
        remember_user_on_this_computer(@user, 1)

        @code = @user.fb_exchange_token_code
        render 'fb_authorize'
      else
        head 406 # not acceptable
      end
    end
  end



  def fb_remember_login
    remember_login = RememberLogin.where({
      remember_token: cookies[:user_token],
      user_id:        cookies[:user_id]
    }).first
    if remember_login.nil? || remember_login.login_type == 0
      head 406 # not acceptable
    else
      user_params = params.require(:user).permit!
      @user = remember_login.user
      if @user.fb_user_id != user_params[:fb_user_id]
        head 406 # not acceptable
      else
        fb_access_token = @user.fb_exchange_long_lived_token(user_params[:fb_access_token])
        @user.fb_access_token = fb_access_token
        @user.save
        session[:user_id] = @user.id
        remember_login.destroy
        remember_user_on_this_computer(@user, 1)

        @code = @user.fb_exchange_token_code
        render 'fb_authorize'
      end
    end
  end



  def email_register
    if params[:password] != params[:password_confirmation]
      render json: {error:    true,
                    message: 'Password and password confirmation does not match.',
                    error_code: 'US000'},
             status: 406
    else
      user = User.create params.permit(:name, :email, :password)
      session[:user_id] = user.id
      remember_user_on_this_computer(user, 0)
      render json: user, except: [:password_salt, :password_hash, :fb_access_token]
    end
  end



  def email_login
    user = User.authorize_with_email(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      remember_user_on_this_computer(user, 0) if params[:remember_me]
      render json: user, except: [:password_salt, :password_hash, :fb_access_token]
    else
      head 406
    end
  end



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


  # --- Private ---

  def remember_user_on_this_computer(user, login_type)
    new_remember_login = RememberLogin.new(login_type: login_type)
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
