class UserSession < ActiveRecord::Base
  
  attr_accessor :request
  attr_accessible :email, :auth_token, :cookies, :j_session_id, :hs_uid, :hs_pid, :fs_auth_token, :hs_auth_token
  
  #validates :email, :presence=>true
  #validates :auth_token, :presence=>true
  #validates :j_session_id, :presence=>true
  #validates :cookies, :presence=>true
  
  serialize :filter_params, Hash
  
  LOGIN_URL = "http://workbench.brandwatch.com/j_acegi_security_check"
  LOGOUT_URL = "http://workbench.brandwatch.com/logout"
  
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
  
  def store_current_state(project_id, brand_id, filter_params = {})
    self.project_id = project_id
    self.brand_id = brand_id
    self.filter_params = filter_params if filter_params.class == Hash && !filter_params.blank?
    self.save
  end
  
  def login_body
    {j_username: email, j_password: fs_auth_token}
  end
  
  def login_params
    {output: "xml"}
  end
  
  def login
    
    Rails.logger.info "Logging to #{LOGIN_URL} in as #{email}"
    request = Typhoeus::Request.new(
      LOGIN_URL,
      method: :post,
      params: login_params,
      body: login_body,
      verbose: true
    )
    
    response = request.run
    self.cookies = response.headers_hash["Set-Cookie"]
    if self.cookies
      hsh = cookies_hash
      self.j_session_id = hsh['JSESSIONID'] if hsh && hsh.has_key?('JSESSIONID')
      save
    else
      Rails.logger.info "Incorrect Cookie : #{cookies}. JSESSIONID not found in cookie."
    end
    Rails.logger.info "Storing the cookies : #{cookies}"
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
