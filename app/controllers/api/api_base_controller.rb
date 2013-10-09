class Api::ApiBaseController < ApplicationController

  before_action :check_login_status
  before_action :find_user

  def check_login_status
    head 401 if session[:user_id].nil?
  end

  def find_user
    @user = User.find(session[:user_id])
  end

  private :check_login_status, :find_user

end
