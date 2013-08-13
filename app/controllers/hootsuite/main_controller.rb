module Hootsuite
  class MainController < Hootsuite::BaseController
    
    #before_filter :check_if_valid_hootsuite_user
    skip_filter :check_if_session_is_expired, :only=>:authenticated
      
    def index
    end
    
    def authenticated
      user_session
      render layout: false
    end
    
  end
end
