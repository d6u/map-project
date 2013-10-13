class InvitationsController < ApplicationController

  # GET    /invitations/:code    show
  # ----------------------------------------
  def show
    if !(@invitation = Invitation.find_by_code params[:code])
      head 404
    elsif
      render layout: 'desktop'
    end
  end

end
