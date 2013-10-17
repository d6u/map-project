class HomeController < ApplicationController

  # Desktop version
  def index
    render :layout => 'desktop'
  end


  # Mobile version
  def mobile_index
    render :layout => false
  end

end
