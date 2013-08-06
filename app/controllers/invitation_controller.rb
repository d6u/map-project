class InvitationController < ApplicationController

  skip_before_action :check_login_status, :only => [:join]


  def generate
    invitation = Invitation.new params.require(:invitation).permit(:project_id)
    @user.invitations << invitation
    render :json => invitation
  end


  def join
    invitation = Invitation.find_by_code params[:code]

    if invitation
      @target_user    = invitation.user
      if invitation.project
        @target_project = invitation.project
        redirect_to '/project/'+@target_project.id if @user && @user.id == @target_user.id
      else
        redirect_to '/' if @user && @user.id == @target_user.id
      end
    else
      redirect_to '/'
    end
  end

end
