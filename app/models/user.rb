require 'net/https'


class User < ActiveRecord::Base

  APP_ID       = $api_keys['facebook']['app_id']
  APP_SECRET   = $api_keys['facebook']['app_secret']


  has_many :projects,    :foreign_key => 'owner_id'
  has_many :friendships
  has_many :followships, :class_name => "Friendship",
                         :foreign_key => "friend_id"
  has_many :friends,      -> { where 'friendships.status > 0' },
                         :through => :friendships
  has_many :followers,   :through => :followships, :source => :user
  has_many :invitations
  has_and_belongs_to_many :participated_projects, :join_table => "project_user", :foreign_key => "user_id", :class_name => 'Project'


  def validate_with_facebook
    fb_access_token = self.fb_access_token
    fb_user_id      = self.fb_user_id

    user_data = MultiJson.load(Net::HTTP.get(URI("https://graph.facebook.com/me?access_token=#{fb_access_token}")))
    return false if !user_data || user_data['error']
    return user_data['id'].to_s === fb_user_id.to_s
  end

end
