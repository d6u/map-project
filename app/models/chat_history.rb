class ChatHistory < ActiveRecord::Base

  belongs_to :user
  belongs_to :project

  validates :user_id,    presence: true
  validates :project_id, presence: true
  validates :item_type,  presence: true

end
