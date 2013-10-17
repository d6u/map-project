class Place < ActiveRecord::Base

  belongs_to :project, :touch => true
  belongs_to :user

  validates :coord, :order, :project_id, :user_id, presence: true

end
