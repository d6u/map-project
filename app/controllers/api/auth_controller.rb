class Api::AuthController < Api::ApiBaseController

  # GET   /api/auth/login_status       #login_status
  # POST  /api/auth/fb_register        #fb_register
  # POST  /api/auth/fb_login           #fb_login
  # POST  /api/auth/fb_remember_login  #fb_remember_login
  # POST  /api/auth/email_login        #email_login
  # POST  /api/auth/email_register     #email_register
  # GET   /api/auth/logout             #logout


  skip_before_action :check_login_status, except: [:logout]
  skip_before_action :find_user         , except: [:logout]


  # GET   /api/auth/login_status
  def login_status
    # session exist
    if !session[:user_id].nil?
      if !( @user = User.find_by_id(session[:user_id]) ).nil?
        render json: @user, only: [:id, :name, :profile_picture, :email]
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
      if !remember_login.nil?
        if remember_login.login_type == 0 # email
          @user = remember_login.user
          remember_login.destroy
          email_auth_process(true)
        elsif remember_login.login_type == 1 # facebook
          render json: {remember_login: true, type: 'facebook'}
        end
        return
      # remember token is invalid
      else
        remove_remember_login_cookies
      end
    end

    # remove incomplete cookies pair
    if cookies[:user_token] || cookies[:user_id]
      remove_remember_login_cookies
    end

    head 404
  end


  # POST  /api/auth/fb_register
  def fb_register
    @user = User.new params.require(:user).permit(:fb_access_token, :fb_user_id, :name, :email, :profile_picture)
    fb_auth_process
  end


  # POST  /api/auth/fb_login
  def fb_login
    user_params = params.require(:user).permit!

    if ( @user = User.find_by_fb_user_id(user_params[:fb_user_id]) ).nil?
      head 406 # not acceptable
    else
      fb_auth_process(user_params[:fb_access_token])
    end
  end


  # POST  /api/auth/fb_remember_login
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
        remember_login.destroy
        fb_auth_process(user_params[:fb_access_token])
      end
    end
  end


  # POST  /api/auth/email_register
  def email_register
    user_params = params.require(:user).permit(:name, :email, :password, :password_confirmation)
    if user_params[:password] != user_params[:password_confirmation]
      render json: {error:    true,
                    message: 'Password and password confirmation does not match.',
                    error_code: 'US000'},
             status: 406
    else
      @user = User.new user_params
      if @user.save
        email_auth_process(true)
      else
        render json: @user.errors, status: 406
      end
    end
  end


  # POST  /api/auth/email_login
  def email_login
    user_params = params.require(:user).permit(:email, :password, :remember_me)
    @user = User.authorize_with_email(user_params[:email], user_params[:password])
    if @user
      email_auth_process(user_params[:remember_me])
    else
      head 406
    end
  end


  # GET   /api/auth/logout
  def logout
    if @user
      if cookies[:user_token]
        RememberLogin.destroy_all({
          user_id:        @user.id,
          remember_token: cookies[:user_token]
        })
      end

      session[:user_id] = nil
      remove_remember_login_cookies
    end
    head 200
  end


  # --- Private ---

  def fb_auth_process(fb_access_token=nil)
    if !fb_access_token.nil?
      fb_access_token = @user.fb_exchange_long_lived_token
    else
      fb_access_token = @user.fb_exchange_long_lived_token(fb_access_token)
    end

    if fb_access_token
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


  def email_auth_process(remember_me)
    session[:user_id] = @user.id
    remember_user_on_this_computer(@user, 0) if remember_me
    render json: @user, except: [:password_salt, :password_hash, :fb_access_token]
  end


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


  def remove_remember_login_cookies
    cookies.delete :user_token, :domain => :all
    cookies.delete :user_id   , :domain => :all
  end


  private :fb_auth_process, :email_auth_process,
          :remember_user_on_this_computer,
          :remove_remember_login_cookies

end
