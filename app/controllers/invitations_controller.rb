class InvitationsController < ApplicationController

  # GET    /invitations/:code    show

  skip_before_action :check_login_status

  # GET    /invitations/:code    show
  # ----------------------------------------
  def show
    head 404 if !(@invitation = Invitation.find_by_code params[:code])
  end

end
