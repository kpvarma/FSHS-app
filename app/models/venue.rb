class Venue
  
  MANAGED_VENUES_URL = "https://api.foursquare.com/v2/simulate/venues/managed"
  VENUE_URL = "https://api.foursquare.com/v2/"
  
  def self.fetch(user_session)
    
    Rails.logger.info "Fetching managed venues from #{MANAGED_VENUES_URL} in as session #id: #{user_session.id}"
    
    request = Typhoeus::Request.new(
      MANAGED_VENUES_URL,
      method: :get,
      params: {oauth_token: user_session.fs_auth_token},
      verbose: true
    )
    
    response = request.run
    
    case response.code
    when 302
      #puts "response.headers[\"location\"] #{response.headers["location"]}".green
      #puts "response.body #{response.body}".red
      if response.headers["location"].index("login")
        raise RequireLoginError
      else
        raise UnknownRedirectionError
      end
    when 404
      raise PageNotFoundError
    when 200
      # Do nothing. Proceed ...
    end
    
    return response.body
  end
  
  def self.fetch_one(user_session, venue_id)
    
    Rails.logger.info "Fetching venue details from #{VENUE_URL} in as session #id: #{user_session.id}"
    
    request = Typhoeus::Request.new(
      VENUE_URL,
      method: :get,
      params: {venue_id: venue_id, oauth_token: user_session.fs_auth_token},
      verbose: true
    )
    response = request.run
    
    case response.code
    when 302
      if response.headers["location"].index("login")
        raise RequireLoginError
      else
        raise UnknownRedirectionError
      end
    when 404
      raise PageNotFoundError
    when 200
      # Do nothing. Proceed ...
    end
    
    return response.body
  end
  
end
