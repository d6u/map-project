class Api::ApiBaseController < ApplicationController

  before_action :check_login_status

  def check_login_status
    head 401 if session[:user_id].nil?
  end

  private :check_login_status

end
