class HomeController < ApplicationController

  skip_before_action :check_login_status

  def index
  end
end
