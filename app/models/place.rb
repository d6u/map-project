class Place < ActiveRecord::Base

  belongs_to :project, :touch => true

  validates :coord, :order, :project_id, presence: true

end
