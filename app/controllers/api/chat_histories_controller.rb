class Api::ChatHistoriesController < Api::ApiBaseController

  # GET   /api/projects/:project_id/chat_histories      #index
  # POST  /api/projects/:project_id/chat_histories      #create
  # GET   /api/projects/:project_id/chat_histories/:id  #show

  before_action :find_project, except: [:show]


  # GET   /api/projects/:project_id/chat_histories
  def index
    if params[:max_id].nil?
      render json: @project.chat_histories.order('id DESC').limit(20)
    else
      render json: @project.chat_histories.where('id <= ?', params[:max_id]).order('id DESC').limit(20)
    end
  end


  # POST  /api/projects/:project_id/chat_histories
  def create
    chat_history = ChatHistory.new params.require(:chat_history).permit(:item_type, content: [:m])
    chat_history.user = @user
    if @project.chat_histories << chat_history
      render json: chat_history
    else
      head 406
    end
  end


  # GET   /api/projects/:project_id/chat_histories/:id
  def show
    chat_history = ChatHistory.find_by_id params[:id]
    if chat_history.nil?
      head 404
    else
      render json: chat_history
    end
  end


  # --- Private ---

  def find_project
    @project = Project.find params[:project_id]
  end

  private :find_project

end
