class Notice < ActiveRecord::Base

  belongs_to :sender  , class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  belongs_to :project

  validates :sender_id, :receiver_id, :notice_type, presence: true


  def self.create_add_friend_request(sender, receiver, friendship, comments=nil)
    sender_id     = (sender.is_a?     Fixnum) ? sender     : sender.id
    receiver_id   = (receiver.is_a?   Fixnum) ? receiver   : receiver.id
    friendship_id = (friendship.is_a? Fixnum) ? friendship : friendship.id

    return Notice.create({
      sender_id:   sender_id,
      receiver_id: receiver_id,
      notice_type: 0,
      content:    {fs_id: friendship_id, m: comments}
    })
  end

end
