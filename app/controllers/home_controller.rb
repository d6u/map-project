class HomeController < ApplicationController

  skip_before_action :check_login_status

  # Desktop version
  def index
    render :layout => false
  end


  # Mobile version
  def mobile_index
    render :layout => false
  end

end
