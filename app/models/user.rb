require 'net/https'
require 'securerandom'
require 'digest/sha1'


class User < ActiveRecord::Base

  APP_ID       = $api_keys['facebook']['app_id']
  APP_SECRET   = $api_keys['facebook']['app_secret']


  # --- Attrs ---
  attr_accessor :password


  # login, remember logins, forget password
  has_many :remember_logins
  has_many :reset_password_tokens

  # project
  has_many :projects, :foreign_key => 'owner_id'

  # friends
  has_many :friendships
  has_many :followships, :class_name => 'Friendship',
                         :foreign_key => 'friend_id'
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


  # --- Facebook Login ---
  def validate_with_facebook
    user_data = MultiJson.load(Net::HTTP.get(URI("https://graph.facebook.com/me?access_token=#{self.fb_access_token}")))
    return false if !user_data || user_data['error']
    return user_data['id'].to_s === self.fb_user_id.to_s
  end


  # --- Email Login ---
  def self.authorize_with_email(user_params, entered_password=nil)
    if entered_password
      email    = user_params
      password = entered_password
    else
      email    = user_params[:email]
      password = user_params[:password]
    end

    user = User.find_by_email(email)
    return false if !user || !user.password_match?(password)
    return user
  end


  def password_match?(entered_password=@current_password)
    self.password_hash === generate_password_hash(entered_password)
  end


  # Return a Hash contains only :id, :name, :profile_picture
  #   this can be used in various situations, e.g. chat message needs to
  #   send some sender information alone with the message
  def public_info
    {:id              => self.id,
     :name            => self.name,
     :profile_picture => self.profile_picture}
  end


  # --- Callbacks ---
  before_create :generate_password_salt_and_hash
  before_update :generate_password_salt_and_hash_if_changed_password


  private
  def generate_password_salt_and_hash
    if @password
      self.password_salt = generate_password_salt
      self.password_hash = generate_password_hash
    end
  end

  def generate_password_salt
    Digest::SHA1.hexdigest("Use #{self.email} with #{Time.now} to make salt")
  end

  def generate_password_hash(entered_password=@password)
    Digest::SHA1.hexdigest("Put #{self.password_salt} on the #{entered_password}")
  end

  def generate_password_salt_and_hash_if_changed_password
    # TODO
  end

end
