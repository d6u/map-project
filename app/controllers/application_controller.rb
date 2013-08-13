class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :validate_session
  before_action :check_login_status

  private

  def validate_session
    if session[:user_id]
      @user = User.find_by_id session[:user_id]
      session[:user_id] = nil if !@user
    end
  end


  def check_login_status
    head 401 if !session[:user_id]
  end


  def authenticate_socket_io_handshake(user)
    user_identifier = SecureRandom.hex.to_s
    cookies[:user_identifier] = {
      :value  => user_identifier,
      :domain => '.' + request.domain
    }
    $redis.set    user_identifier, "#{user.id}:#{user.name}"
    $redis.expire user_identifier, 172800
  end

end
