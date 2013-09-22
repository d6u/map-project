require 'securerandom'


class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :reset_session

  before_action :validate_user_identity
  before_action :check_login_status


  # --- Private ---

  def validate_user_identity
    if session[:user_id]
      @user = User.find_by_id session[:user_id]
      session[:user_id] = nil if !@user
    elsif cookies[:user_token] && cookies[:user_id]
      remember_login = RememberLogin.where({
        remember_token: cookies[:user_token],
        user_id:        cookies[:user_id]
      })
      if remember_login
        @user = remember_login.user
        session[:user_id] = @user.id

        remember_user_on_this_computer

        remember_login.destroy
      else
        cookies.delete :user_token, :domain => :all
        cookies.delete :user_id   , :domain => :all
      end
    end
  end


  # Head 401 if no session[:user_id], i.e. unauthorized
  def check_login_status
    head 401 if !session[:user_id]
  end

  private :validate_user_identity, :check_login_status


  # --- Protected ---

  def remember_user_on_this_computer
    new_remember_login = RememberLogin.new
    @user.remember_logins << new_remember_login
    cookies[:user_token] = {
      value:   new_remember_login.remember_token,
      domain:  '.' + request.domain,
      expires: 3.month.from_now
    }
    cookies[:user_id] = {
      value:   @user.id,
      domain:  '.' + request.domain,
      expires: 3.month.from_now
    }
    new_remember_login
  end

  protected :remember_user_on_this_computer

end
