class Api::AuthController < Api::ApiBaseController

  skip_before_action :check_login_status

  def login_status

  end

end
