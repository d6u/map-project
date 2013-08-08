require 'securerandom'


class HomeController < ApplicationController

  skip_before_action :check_login_status

  def index
    if @user
      # socket.io
      unless cookies[:user_identifier] && $redis.get(cookies[:user_identifier]) &&  $redis.ttl(cookies[:user_identifier]) >= 600
        user_identifier = SecureRandom.hex.to_s
        cookies[:user_identifier] = {
          :value  => user_identifier,
          :domain => '.' + request.domain
        }
        $redis.set    user_identifier, "#{@user.id}:#{@user.name}"
        $redis.expire user_identifier, 172800
      end
    end
  end


  def index_async
    if @user
      # socket.io
      unless cookies[:user_identifier] && $redis.get(cookies[:user_identifier]) &&  $redis.ttl(cookies[:user_identifier]) >= 600
        user_identifier = SecureRandom.hex.to_s
        cookies[:user_identifier] = {
          :value  => user_identifier,
          :domain => '.' + request.domain
        }
        $redis.set    user_identifier, "#{@user.id}:#{@user.name}"
        $redis.expire user_identifier, 172800
      end
    end
    render :layout => false
  end

end
