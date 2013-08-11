require 'net/http'


class User < ActiveRecord::Base

  APP_ID       = 580227458695144
  REDIRECT_URL = 'http://local.dev:3000/fb_login_successful'
  APP_SECRET   = 'f4977efd531a4f5ebb2ceb678646f0ab'


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

    user_data = MultiJson.load(Net::HTTP.get(URI("https://graph.facebook.com/debug_token?input_token=#{fb_access_token}&access_token=#{fb_access_token}")))
    return false if !user_data || !user_data['data']
    return user_data['data']['is_valid'] && user_data['data']['user_id'].to_s === fb_user_id
  end

end
