class SessionsController < ApplicationController
  
  layout 'public'
  before_filter :check_if_session_is_valid, :except=>:destroy
  #before_filter :check_if_valid_hootsuite_user
  
  # GET /
  def new
    respond_to do |format|
      format.html { }
      format.json { head :no_content }
      format.xml {}
    end
  end
  
  def create
    fs_auth_token = params["code"]
    @user_session = UserSession.find_by_id(params['session_id'])
    @user_session.fs_auth_token = fs_auth_token
    @user_session.save
    
    unless @user_session.valid?
      redirect_to new_session_path
      return
    else
      #@user_session.login
    end
    
    # Next requests should have auth_token either in params or in headers.
    # This will redirect to a authenticated page which will close automatically.
    redirect_to hootsuite_authenticated_path(api_token: @user_session.auth_token)
    
  end
  
  def destroy
    @user_session = UserSession.find_by_id(params[:id])
    
    if @user_session
      hs_pid = @user_session.hs_pid
      hs_uid = @user_session.hs_uid
      hs_auth_token = @user_session.hs_auth_token
      #@user_session.logout
      @user_session.delete
    end
    
    # Generate redirect_url with hootsuite params
    redirect_url = new_session_path(
                                      :pid => hs_pid,
                                      :uid => hs_uid,
                                      :i => params['i'],
                                      :isSsl => params['isSsl'],
                                      :lang => params['lang'],
                                      :theme => params['theme'],
                                      :timezone => params['timezone'],
                                      :token => hs_auth_token,
                                      :ts => params['ts']
                                   )
    
    redirect_to redirect_url
    
  end
  
end
