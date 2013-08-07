class InvitationController < ApplicationController

  skip_before_action :check_login_status, :only => [:join]


  def generate
    invitation = Invitation.new params.require(:invitation).permit(:project_id)
    @user.invitations << invitation
    render :json => invitation
  end


  # GET
  def join
    invitation = Invitation.find_by_code params[:code]

    if invitation
      # invitation exist
      @target_user = invitation.user
      # user is the same with invitation creator
      redirect_to '/' and return if @user && @user.id == @target_user.id
      @target_project = invitation.project if invitation.project
    else
      # invitation not exist
      redirect_to '/'
    end
  end


  # POST
  def joined
    invitation = Invitation.find_by_code params[:code]

    if invitation
      # invitation exist
      @target_user = invitation.user
      # user is the same with invitation creator
      redirect_to '/' and return if @user && @user.id == @target_user.id
      @target_project = invitation.project if invitation.project
    else
      # invitation not exist
      redirect_to '/' and return
    end

    # add friend
    @target_user.friends << @user
    target_user_friendship = @target_user.friendships.find_by_friend_id @user.id
    target_user_friendship.status = 1
    target_user_friendship.save

    @user.friends << @target_user
    user_friendship = @user.friendships.find_by_friend_id @target_user.id
    user_friendship.status = 1
    user_friendship.save

    # add project if any
    if @target_project
      @user.participated_projects << @target_project
      render :json => @target_project and return
    end
    render :json => {id: nil}
  end

end
