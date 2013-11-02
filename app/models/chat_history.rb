class ChatHistory < ActiveRecord::Base

  belongs_to :user
  belongs_to :project

  validates :user_id,    presence: true
  validates :project_id, presence: true
  validates :item_type,  presence: true


  # {pl_id: place_id, pl_rf: "reference string for Google API"}
  #
  def self.create_place_added(user_id, project_id, place_id, place_reference)
    return ChatHistory.create({
      user_id:    user_id,
      project_id: project_id,
      item_type:  1,
      content: {
        pl_id: place_id,
        pl_rf: place_reference
      }
    })
  end


  # {pl_rf: "reference string for Google API"}
  #
  def self.create_place_removed(user_id, project_id, place_reference)
    return ChatHistory.create({
      user_id:    user_id,
      project_id: project_id,
      item_type:  2,
      content: {
        pl_id: place_id,
        pl_rf: place_reference
      }
    })
  end

end
