class Api::InvitationsController < Api::ApiBaseController

  # GET     /api/invitations/:code/accept_invitation  accept_invitation
  # GET     /api/invitations      index
  # POST    /api/invitations      create
  # DELETE  /api/invitations/:id  destroy


  # GET     /api/invitations/:code/accept_invitation  accept_invitation
  # ----------------------------------------
  def accept_invitation
    invitation = Invitation.find_by_code params[:code]
    head 404 and return if !invitation

    @user.friends << invitation.user
    invitation.user.friends << @user

    if invitation.project
      @user.participating_projects << invitation.project
    end
    head 200
  end


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
