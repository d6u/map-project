class Api::PlacesController < Api::ApiBaseController

  #  GET     /api/projects/:project_id/places       #index
  #  POST    /api/projects/:project_id/places       #create
  #  GET     /api/projects/:project_id/places/:id   #show
  #  PATCH   /api/projects/:project_id/places/:id   #update
  #  PUT     /api/projects/:project_id/places/:id   #update
  #  DELETE  /api/projects/:project_id/places/:id   #destroy


  before_action :load_project


  #  GET     /api/projects/:project_id/places       #index
  def index
    places = Place.where(:project_id => params[:project_id]).order 'places.order ASC'
    render :json => places
  end


  #  POST    /api/projects/:project_id/places       #create
  def create
    place      = Place.new(params.require(:place)
      .permit(:notse, :name, :address, :coord, :order, :reference))
    place.user = @user
    @project.places << place
    render :json => place

    # send placeAdded event to Node server
    (@project.participating_users + [@project.owner]).each do |user|
      place_added = {
        type:        'placeAdded',
        sender:      @user.public_info,
        receiver_id: user.id,
        place:       place
      }
      $redis.publish 'notice_channel', MultiJson.dump(place_added)
    end
  end


  def show
    place = Place.find_by_id params[:id]
    render :json => place
  end


  def update
    place = Place.find_by_id params[:id]
    place.attributes = params.require(:place).permit(:notse, :name, :address, :coord, :order)
    place.save if place.changed?
    render :json => place
  end


  def destroy
    Place.destroy_all :id => params[:id]
    head 200
  end


  # --- Private ---

  def load_project
    @project = Project.find(params[:project_id]) if !params[:project_id].nil?
  end

  private :load_project

end
