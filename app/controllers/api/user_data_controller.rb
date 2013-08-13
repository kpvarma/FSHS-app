module Api
  class UserDataController < Api::BaseController
  
    before_filter :set_navs
  
    def index
      set_nav("User Data")
      set_navbar("User Data")
      set_title("User Data")
      @user_data = UserData.fetch(@user_session)
    end
  
    def index
    
      proc_code = Proc.new do
        @user_data, @xml_string = UserData.fetch(@user_session)
        set_title(@user_session.email)
        @json_object = @user_data.as_json
      end
    
      ## Go to ApplicationController to view the defenition of render_the_response
      render_the_response(proc_code)
    
    end
  
    private
  
    def set_navs
      set_nav("User Data")
      set_navbar("User Data")
    end
  
  end
end
