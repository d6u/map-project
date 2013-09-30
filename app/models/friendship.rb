class Friendship < ActiveRecord::Base

  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"


  # --- Validations ---
  validates :user_id, :friend_id, :status, presence: true
  validates :friend_id, uniqueness: {scope: :user_id}

  validates_each :user_id, :friend_id, if: Proc.new {|a| !a.new_record?} do |record, attr, value|
    record.errors[attr] << 'cannot be changed' if record.changed.include? attr.to_s
  end


  <<-DOC
  Used to generate friendship record with a reversed order of user_id and
    friend_id from current one, with the same status. This method is only used
    in generating friendship when user accepts friends request. Newly generated
    friendship object will not be saved.
  DOC
  def reverse_friendship
    friendship = Friendship.where({
      :user_id   => self.friend_id,
      :friend_id => self.user_id
    })[0]
    if friendship
      return friendships
    else
      return Friendship.new({
        user_id:   self.friend_id,
        friend_id: self.user_id,
        status:    self.status
      })
    end
  end

end
