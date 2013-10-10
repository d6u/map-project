require 'net/https'
require 'securerandom'
require 'digest/sha1'


class User < ActiveRecord::Base

  APP_ID       = $api_keys['facebook']['app_id']
  APP_SECRET   = $api_keys['facebook']['app_secret']
  FB_API_BASE  = 'https://graph.facebook.com'


  # login, remember logins, forget password
  has_many :remember_logins      , dependent: :destroy
  has_many :reset_password_tokens, dependent: :destroy

  # project
  has_many :projects             , dependent: :destroy,
                                   foreign_key: 'owner_id'
  has_many :places

  # friends
  has_many :friendships          , dependent:   :destroy
  has_many :followships          , dependent:   :destroy,
                                   class_name:  'Friendship',
                                   foreign_key: 'friend_id'

  has_many :friends, -> { where 'friendships.status > 0' },
                     :through => :friendships
  has_many :followers, :through => :followships, :source => :user

  # projects participations
  has_many :project_participations, :dependent => :destroy
  has_many :participating_projects,
    -> { where 'project_participations.status > 0' },
    :through => :project_participations,
    :source  => :project
  has_many :pending_project_invitations,
    -> { where 'project_participations.status = 0' },
    :through => :project_participations,
    :source  => :project

  # invitation
  has_many :invitations, dependent: :destroy


  # --- Attrs ---
  attr_accessor :password
  attr_accessor :password_confirmation


  # --- Validations ---
  EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i
  validates :name,          presence: true
  validates :email,         uniqueness: {case_sensitive: false}, format: {with: EMAIL_REGEX}, allow_nil: true
  validates :fb_user_id,    presence: true, uniqueness: {case_sensitive: false}, unless: Proc.new {|a| a.fb_access_token.nil?}
  validates :password,      confirmation: true, length: {minimum: 8}, allow_nil: true
  validates :password_hash, presence: true, unless: Proc.new {|a| a.password_salt.nil?}
  validates :password_salt, presence: true, unless: Proc.new {|a| a.password_hash.nil?}


  # --- Facebook Authentication ---
  def fb_exchange_long_lived_token(short_lived_token=self.fb_access_token)
    data = call_facebook '/oauth/access_token', {
      grant_type:       'fb_exchange_token',
      client_id:         APP_ID,
      client_secret:     APP_SECRET,
      fb_exchange_token: short_lived_token
    }
    if data["access_token"].nil?
      return false
    else
      return data["access_token"]
    end
  end


  def fb_exchange_token_code(long_lived_access_token=self.fb_access_token)
    data = call_facebook '/oauth/client_code', {
      access_token:  long_lived_access_token,
      client_id:     APP_ID,
      client_secret: APP_SECRET,
      redirect_uri: 'http://local.dev',
    }
    if data["code"].nil?
      return false
    else
      return data["code"]
    end
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


  # [method, ]path, query
  #   method: Symbol, e.g. :get
  #   path:   String, e.g. '/me'
  #   query:  Hash,   e.g. {access_token: '12345678'}
  # private method
  def call_facebook(*args)
    if args[0].class == Symbol
      method = args[0]
      path   = args[1]
      params = args[2]
    else
      method = :get
      path   = args[0]
      params = args[1]
    end

    url   = (path =~ /^\/.+/) ? (FB_API_BASE+path) : (FB_API_BASE+'/'+path)
    uri   = URI.parse(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    case method.to_s.upcase
    when 'GET'
      uri.query   = URI.encode_www_form(params)
      api_request = Net::HTTP::Get.new(uri.request_uri)
    when 'POST'
      api_request = Net::HTTP::Post.new(uri.request_uri)
      api_request.set_form_data(params) if !params.empty?
    end

    api_reponse = https.request(api_request)
    begin
      MultiJson.load(api_reponse.body)
    rescue MultiJson::LoadError
      begin
        Hash[URI.decode_www_form(api_reponse.body)]
      rescue ArgumentError
        api_reponse.body
      end
    end
  end


  private :generate_password_salt_and_hash, :generate_password_salt,
          :generate_password_hash,
          :generate_password_salt_and_hash_if_changed_password,
          :call_facebook

end
