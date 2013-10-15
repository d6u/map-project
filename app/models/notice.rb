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


  # sender, receiver
  def self.create_add_friend_request_accepted(s, r)
    sender_id   = get_id(s)
    receiver_id = get_id(r)

    return Notice.create({
      sender_id:   sender_id,
      receiver_id: receiver_id,
      notice_type: 5
    })
  end


  # sender, receiver, project, project_participation
  def self.create_project_invitation(s, r, p, pp, comments=nil)
    sender_id   = get_id(s)
    receiver_id = get_id(r)
    project_id  = get_id(p)
    pp_id       = get_id(pp)

    return Notice.create({
      sender_id:   sender_id,
      receiver_id: receiver_id,
      project_id:  project_id,
      notice_type: 10,
      content:    {pp_id: pp_id, m: comments}
    })
  end


  # sender, receiver, project
  def self.create_project_invitation_accepted(s, r, p)
    sender_id   = get_id(s)
    receiver_id = get_id(r)
    project_id  = get_id(p)

    return Notice.create({
      sender_id:   sender_id,
      receiver_id: receiver_id,
      project_id:  project_id,
      notice_type: 15
    })
  end


  # sender, receiver, project
  def self.create_project_invitation_rejected(s, r, p)
    sender_id   = get_id(s)
    receiver_id = get_id(r)
    project_id  = get_id(p)

    return Notice.create({
      sender_id:   sender_id,
      receiver_id: receiver_id,
      project_id:  project_id,
      notice_type: 16
    })
  end


  # sender, receiver, project,
  def self.create_new_user_added(s, r, p)
    sender_id   = get_id(s)
    receiver_id = get_id(r)
    project_id  = get_id(p)

    return Notice.create({
      sender_id:   sender_id,
      receiver_id: receiver_id,
      project_id:  project_id,
      notice_type: 25
    })
  end


  # sender, receiver, project
  def self.create_your_are_removed_from_project(s, r, p, comments=nil)
    sender_id   = get_id(s)
    receiver_id = get_id(r)
    project_id  = get_id(p)

    return Notice.create({
      sender_id:   sender_id,
      receiver_id: receiver_id,
      project_id:  project_id,
      notice_type: 45,
      content:    {m: comments}
    })
  end


  # sender, receiver, project
  def self.create_project_user_list_updated(s, r, p, comments=nil)
    sender_id   = get_id(s)
    receiver_id = get_id(r)
    project_id  = get_id(p)

    return Notice.create({
      sender_id:   sender_id,
      receiver_id: receiver_id,
      project_id:  project_id,
      notice_type: 26,
      content:    {m: comments}
    })
  end


  # --- Private ---

  def self.get_id(object)
    return (object.is_a? Fixnum) ? object : object.id
  end

  private_class_method :get_id

end
