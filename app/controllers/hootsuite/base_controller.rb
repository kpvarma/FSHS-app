module Hootsuite
  class BaseController < ApplicationController
  
    layout 'hootsuite'
  
    before_filter :check_if_session_is_expired
  
  end
end
