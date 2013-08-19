module Api
  class ManagedVenuesController < Api::BaseController
  
    def index
    
      proc_code = Proc.new do
        @json_string = Venue.fetch(@user_session)
        @managed_venues = JSON.parse(@json_string) if request.format.to_s.downcase == "text/html"
      end
    
      ## Go to ApplicationController to view the defenition of render_the_response
      render_the_response(proc_code)
    
    end
  
    def show
      ## Redirect to projects index page if params not passed.
      redirect_to api_projects_path unless params[:id]
    
      proc_code = Proc.new do
        @project, @xml_string = Project.fetch_one(@user_session, params[:id])
        set_title(@project.name)
        @json_object = @project.as_json
      end
    
      ## Go to ApplicationController to view the defenition of render_the_response
      render_the_response(proc_code)
    
    end
  
  end
end
