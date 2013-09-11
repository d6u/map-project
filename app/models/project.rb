class Project < ActiveRecord::Base

  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"
  has_many   :places, :dependent => :destroy

  # participations
  has_many :project_participations, :dependent => :destroy
  has_many :participating_users, -> { where 'project_participations.status > 0' },
                                 :through => :project_participations,
                                 :source  => :user
  has_many :pending_user_invitations, -> { where 'project_participations.status = 0' },
                                      :through => :project_participations,
                                      :source  => :user


  def places_attrs
    places = self.places
    places_coords = places.map {|place| place.coord}

    {
      :places_count => places.size,
      :places_coords => places_coords
    }
  end

end
