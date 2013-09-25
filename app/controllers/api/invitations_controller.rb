module Api

class InvitationsController < ApplicationController

  # GET     /api/invitations      index
  # POST    /api/invitations      create
  # DELETE  /api/invitations/:id  destroy


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


  # GET    /invitations/:code    show
  # ----------------------------------------
  def show
    head 404 if !(@invitation = Invitation.find_by_code params[:code])
  end


  # DELETE  /api/invitations/:id  destroy
  # ----------------------------------------
  def destroy
    Invitation.destroy_all(id: params[:id])
    head 200
  end

end

end
