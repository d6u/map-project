class Place < ActiveRecord::Base

  belongs_to :project, :touch => true

end
