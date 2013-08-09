class PlacesController < ApplicationController

  #     places GET    /places(.:format)            places#index
  #            POST   /places(.:format)            places#create
  #  new_place GET    /places/new(.:format)        places#new
  # edit_place GET    /places/:id/edit(.:format)   places#edit
  #      place GET    /places/:id(.:format)        places#show
  #            PATCH  /places/:id(.:format)        places#update
  #            PUT    /places/:id(.:format)        places#update
  #            DELETE /places/:id(.:format)        places#destroy


  def index
    places = Place.where(:project_id => params[:project_id]).order 'places.order ASC'
    render :json => places
  end


  def create
    project = Project.find_by_id params[:project_id]

    if project
      place = Place.new params.require(:place).permit(:notse, :name, :address, :coord, :order)
      project.places << place
      render :json => place
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

end
