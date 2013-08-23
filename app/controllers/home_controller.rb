require 'securerandom'


class HomeController < ApplicationController

  skip_before_action :check_login_status

  def index
    if @user
      # socket.io
      unless cookies[:user_identifier] && $redis.get(cookies[:user_identifier]) &&  $redis.ttl(cookies[:user_identifier]) >= 600
        authenticate_socket_io_handshake(@user)
      end
    end
  end


  def index_async
    if @user
      # socket.io
      unless cookies[:user_identifier] && $redis.get(cookies[:user_identifier]) &&  $redis.ttl(cookies[:user_identifier]) >= 600
        authenticate_socket_io_handshake(@user)
      end
    end
    render :layout => false
  end

end
