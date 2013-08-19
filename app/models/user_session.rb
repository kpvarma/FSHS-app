class UserSession < ActiveRecord::Base
  
  attr_accessor :request
  attr_accessible :auth_token, :cookies, :hs_uid, :hs_pid, :fs_auth_token, :hs_auth_token
  
  validates :auth_token, :uniqueness => true
  validates :hs_pid, :uniqueness => {:scope => :hs_uid}
  
  serialize :filter_params, Hash
  
  LOGIN_URL = "https://foursquare.com/oauth2/access_token"
  
  before_create :generate_auth_token
  
  # This function is used to find the user session using hootsuite uid and pid
  # this is mostly used to check if the session is valid in sessions/new page where we dont have our auth_token but only hs uid and pid.
  def self.find_by_uid_and_pid(uid, pid)
    UserSession.where({hs_uid: uid.to_s, hs_pid: pid.to_s}).first
  end
  
  # Check if user session exists
  # Create one with the passed uid, pid if one doesn't exists
  def self.find_or_create_user_session_from_hs_uid_and_pid(uid, pid, hs_auth_token)
    user_session = UserSession.find_by_uid_and_pid(uid, pid)
    user_session = UserSession.create(hs_uid: uid.to_s, hs_pid: pid.to_s, hs_auth_token: hs_auth_token) unless user_session
    return user_session
  end
  
  # Each time a user session is created, an auth token should be created with which the rails api authenticates the user.
  def generate_auth_token
    self.auth_token = SecureRandom.hex
  end
  
  def login(client_id, client_secret, redirect_uri, code, grant_type)
    
    Rails.logger.info "Logging to #{LOGIN_URL}"
    
    request = Typhoeus::Request.new(
      LOGIN_URL,
      method: :get,
      params: { client_id: client_id, client_secret: client_secret, grant_type: grant_type, code: code, redirect_uri: redirect_uri },
      headers: { Accept: "text/json" }
    )
    
    request.run
    response = request.response
    json = JSON.parse(response.body)
    fs_auth_token = json['access_token']
    
    self.fs_auth_token = fs_auth_token
    self.save
    
    Rails.logger.info "Logged in successfully and stored the access_token for further use"
  end
  
  def logout
    Rails.logger.info "Logging out : #{email}"
    request = Typhoeus::Request.new(
      LOGOUT_URL,
      method: :get,
      verbose: true
    )
    response = request.run
  end
  
  def cookies_hash
    CookieJar.new.parse(self.cookies)
  end
  
end
