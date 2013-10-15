class Api::NoticesController < Api::ApiBaseController

  # GET    /api/notices                                #index
  # DELETE /api/notices/:id                            #destroy
  # POST   /api/notices/:id/accept_friend_request      #accept_friend_request
  # DELETE /api/notices/:id/ignore_friend_request      #ignore_friend_request
  # POST   /api/notices/:id/accept_project_invitation  #accept_project_invitation
  # DELETE /api/notices/:id/reject_project_invitation  #reject_project_invitation


  before_action :find_notice, except: [:index]


  # GET    /api/notices
  def index
    render json: @user.received_notices
  end


  # DELETE /api/notices/:id
  def destroy
    @notice.destroy
    render json: @notice
  end



  def accept_friend_request

  end



  def ignore_friend_request

  end



  def accept_project_invitation

  end



  def reject_project_invitation

  end


  # --- Private ---

  def find_notice
    @notice = Notice.find(params[:id])
  end

  private :find_notice

end
