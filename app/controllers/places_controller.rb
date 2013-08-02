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
    # TODO: project_id route
    places = Place.where :project_id => params[:id]
    render :json => places
  end


  def create
    place = Place.new params.require(:place).permit(:notse, :name, :address, :coord, :order, :project_id)
    if place.save
      render :json => place
    end
  end


  def destroy
    Place.destroy_all :id => params[:id]
    head 200
  end

end
