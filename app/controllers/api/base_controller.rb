module Api
  class BaseController < ApplicationController
  
    layout 'api'
    
    before_filter :check_if_session_is_expired
  
  end
end
