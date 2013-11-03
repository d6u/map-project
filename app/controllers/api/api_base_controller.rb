class Api::ApiBaseController < ApplicationController

  before_action :check_login_status
  before_action :find_user

  # --- Protected ---

  def send_push_notice(notice)
    $redis.publish 'notice_channel', notice.to_json
  end

  def push_chat_hisotry_to_clients(chat_history)
    $redis.publish 'chat_channel', chat_history.to_json
  end

  protected :send_push_notice, :push_chat_hisotry_to_clients


  # --- Private ---

  def check_login_status
    head 401 if session[:user_id].nil?
  end

  def find_user
    @user = User.find(session[:user_id])
  end

  private :check_login_status, :find_user

end
