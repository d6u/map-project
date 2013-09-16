require 'net/https'


class User < ActiveRecord::Base

  APP_ID       = $api_keys['facebook']['app_id']
  APP_SECRET   = $api_keys['facebook']['app_secret']


  has_many :projects, :foreign_key => 'owner_id'

  # friends
  has_many :friendships
  has_many :followships, :class_name => "Friendship",
                         :foreign_key => "friend_id"
  has_many :friends, -> { where 'friendships.status > 0' },
                     :through => :friendships
  has_many :followers, :through => :followships, :source => :user

  # projects participations
  has_many :project_participations, :dependent => :destroy
  has_many :participating_projects, -> { where 'project_participations.status > 0' },
                                    :through => :project_participations,
                                    :source  => :project
  has_many :pending_project_invitations, -> { where 'project_participations.status = 0' },
                                         :through => :project_participations,
                                         :source  => :project


  def validate_with_facebook
    fb_access_token = self.fb_access_token
    fb_user_id      = self.fb_user_id

    user_data = MultiJson.load(Net::HTTP.get(URI("https://graph.facebook.com/me?access_token=#{fb_access_token}")))
    return false if !user_data || user_data['error']
    return user_data['id'].to_s === fb_user_id.to_s
  end


  # Return a Hash contains only :id, :name, :fb_user_picture
  #   this can be used in various situations, e.g. chat message needs to
  #   send some sender information alone with the message
  def public_info
    {:id              => self.id,
     :name            => self.name,
     :fb_user_picture => self.fb_user_picture}
  end

end
