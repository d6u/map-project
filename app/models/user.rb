require 'net/http'


class User < ActiveRecord::Base

  APP_ID       = 153060941567545
  REDIRECT_URL = 'http://iwantmap.com/fb_login_successful'
  APP_SECRET   = 'f41e82a1be4342b6154972013e5a543c'
  DEVELOPER_ACCESS_TOKEN = 'CAACLNUcNFjkBAP6wskXaSGkKTgihUPhsIg9WXAY20mcot7GicGZBqV8rzdFJLNUAawIcx4wp3B9Xpd13nvH8vrZAkhuP54NWBI0kgbM5Uy5QcwuRFPZAjAAwHOGQqasztJZBB4Ao76IsMuySNLI6stRi145ZCN9ksBfPSZAkYE3QZDZD'


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
