class Notice < ActiveRecord::Base

  belongs_to :sender  , class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  belongs_to :project

  validates :sender_id, :receiver_id, :notice_type, presence: true

end
