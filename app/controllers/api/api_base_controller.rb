class Api::ApiBaseController < ApplicationController

  before_action :check_login_status
  before_action :find_user

  # --- Protected ---

  def send_push_notice(notice)
    $redis.publish 'notice_channel', notice.to_json
  end

  protected :send_push_notice


  # --- Private ---

  def check_login_status
    head 401 if session[:user_id].nil?
  end

  def find_user
    @user = User.find(session[:user_id])
  end

  private :check_login_status, :find_user

end
