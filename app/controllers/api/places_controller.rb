class Api::PlacesController < Api::ApiBaseController

  #  GET     /api/projects/:project_id/places       #index
  #  POST    /api/projects/:project_id/places       #create
  #  GET     /api/projects/:project_id/places/:id   #show
  #  PATCH   /api/projects/:project_id/places/:id   #update
  #  PUT     /api/projects/:project_id/places/:id   #update
  #  DELETE  /api/projects/:project_id/places/:id   #destroy


  before_action :load_project
  before_action :load_place, only: [:show, :update, :destroy]


  #  GET     /api/projects/:project_id/places       #index
  def index
    render json: @project.places
  end


  #  POST    /api/projects/:project_id/places       #create
  def create
    @place = Place.new params.require(:place).permit(:notse, :name, :address, :coord, :order, :reference)
    @place.user = @user
    @project.places << @place
    render :json => @place

    # send placeAdded event to Node server
    chat_history = ChatHistory.create_place_added(@user.id, @project.id, @place.id, @place.reference)
    push_chat_hisotry_to_clients(chat_history)
  end


  def show
    render json: @place
  end


  def update
    @place.attributes = params.require(:place).permit(:notse, :name, :address, :coord, :order, :reference)
    @place.save if @place.changed?
    render json: @place
  end


  def destroy
    @place.destroy
    render json: @place

    # send placeAdded event to Node server
    chat_history = ChatHistory.create_place_removed(@user.id, @project.id, @place.reference)
    push_chat_hisotry_to_clients(chat_history)
  end


  # --- Private ---

  def load_project
    @project = Project.find(params[:project_id])
  end

  def load_place
    @place = @project.places.find_by_id(params[:id])
    head 406 if @place.nil?
  end

  private :load_project, :load_place

end
