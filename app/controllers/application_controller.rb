require 'securerandom'


class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :validate_session
  before_action :check_login_status

  private
  # Remove invalid session[:user_id]
  def validate_session
    if session[:user_id]
      @user = User.find_by_id session[:user_id]
      session[:user_id] = nil if !@user
    end
  end

  # Head 401 if no session[:user_id], i.e. unauthorized
  def check_login_status
    head 401 if !session[:user_id]
  end

end
