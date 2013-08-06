class Project < ActiveRecord::Base

  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"
  has_many   :places, :dependent => :destroy
  has_many   :invitations


  def places_attrs
    places = self.places
    places_coords = places.map {|place| place.coord}

    {
      :places_count => places.size,
      :places_coords => places_coords
    }
  end

end
