class InvitationsController < ApplicationController

  # GET     /api/invitations      index
  # POST    /api/invitations      create
  # GET     /api/invitations/:id  show
  # DELETE  /api/invitations/:id  destroy


  skip_before_action :check_login_status, :except => [:show]


  # GET    /api/invitations      index
  # ----------------------------------------
  def index
    render json: @user.invitations
  end


  # POST   /api/invitations      create
  # ----------------------------------------
  def create
    invitation = Invitation.new params.require(:invitation).permit(:project_id, :email, :message, :invitation_type)
    @user.invitations << invitation
    render json: invitation
  end


  # GET    /api/invitations/:id  show
  # ----------------------------------------
  def show

  end


  # DELETE  /api/invitations/:id  destroy
  # ----------------------------------------
  def destroy
    Invitation.destroy_all(id: params[:id])
    head 200
  end

end
