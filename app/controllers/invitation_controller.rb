class InvitationController < ApplicationController

  # GET    /api/invitations      index
  # POST   /api/invitations      create
  # GET    /api/invitations/:id  show

  skip_before_action :check_login_status, :except => [:show]


  # GET    /api/invitations      index
  # ----------------------------------------
  def index
    render json: @user.invitations
  end


  # POST   /api/invitations      create
  # ----------------------------------------
  def create
    invitation = Invitation.new params.require(:invitation).permit(:project_id, :email, :message)
    @user.invitations << invitation
    render json: invitation
  end


  # GET    /api/invitations/:id  show
  # ----------------------------------------
  def show

  end

end
