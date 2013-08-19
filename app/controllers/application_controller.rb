class PermissionDeniedError < RuntimeError; end
class RequireLoginError < RuntimeError; end
class UnknownRedirectionError < RuntimeError; end
class PageNotFoundError < RuntimeError; end

class ApplicationController < ActionController::Base
  
  require 'digest/sha1'
  
  private
  
  def check_if_session_is_valid
    
    #puts "params['uid']: #{params['uid']}".red if Rails.env == "development"
    #puts "params['pid']: #{params['pid']}".red if Rails.env == "development"
    
    ## Check if user session exists
    ## Create one with the passed uid, pid if one doesn't exists
    if params['uid'] && params['pid']
      @user_session = UserSession.find_or_create_user_session_from_hs_uid_and_pid(params['uid'], params['pid'], params['token'])
    elsif params['id']
      @user_session = UserSession.find_by_id(params[:id])
    end
    
    #puts "@user_session.id #{@user_session.id}".green if Rails.env == "development"
    
    ## Check if the user is authenticated with Brandwatch.
    ## It will have a valid fs_auth_token which wont be null.
    redirect_to hootsuite_landing_page_path(:params => params) if @user_session && @user_session.id && @user_session.fs_auth_token
    
    return
  end
  
  def user_session
    
    uid = params['uid']
    pid = params['pid']
    api_token = request.headers['api_token'] || params['api_token']
    
    #puts "#{uid}-#{pid}-#{api_token}".red #if Rails.env == "development"
    
    if uid && pid
      @user_session = UserSession.find_by_uid_and_pid(uid, pid)
    elsif api_token
      @user_session = UserSession.find_by_auth_token(api_token)
    end
    
  end
  
  def check_if_session_is_expired
    
    user_session
    
    if @user_session
      redirect_to new_session_path(:params => params) unless @user_session.fs_auth_token
    else
      redirect_to new_session_path(:params => params)
    end
    return
  end
  
  def check_if_valid_hootsuite_user
    ## Check if a valid hootsuite id is present in session
    if cookies["HSi"].blank? || cookies["HSts"].blank? || cookies["HStoken"].blank?
      ## Delete session
      session.delete(:id)
      ## Redirect the user to login page
      redirect_to new_session_path
    else
      ## We need to do authentication with HS. The user will have a session with HootSuite that we can authenticate using SSO (https://hootsuite.com/developers/app-directory/docs/authentication). We need to create user sessions based on that, and retrieve them later. If there is no valid auth token, we need get authentication page, otherwise we redirect the stream.
    
      ## When hootsuite loads our app every time, the query string will contain ?ts=<timestamp>&i=<user_id>&token=<token>. These need to be compared in the following way SHA1( i + ts + secret) === token. If this evaluates to true, then we know that the user_id is authentic. 
      ## We want to base our sessions on authentic Hootsuite session Id. If it exists, we get the BW api key associated with a user and redirect to landing_page. If the Hootsuite_user_id does not exist or is not authenticated with BW in rails, we need to redirect to Authenticate page to generate a new rails_session_id to be stored in association with the new Hootsuite_user_id. Once they authenticate with BW, we will also store the BW api key in the same rails_session_id.
      ## Our shared secret: SOfM@)S+&{<7&k,8^=lxmjvd!0SiT-rx~Vwj-n&/GAO^v1p0M+FEvph9)8$`!NA/
    
      secret_key = "SOfM@)S+&{<7&k,8^=lxmjvd!0SiT-rx~Vwj-n&/GAO^v1p0M+FEvph9)8$`!NA/"
      hs_i = cookies["HSi"]
      hs_ts = cookies["HSts"]
      hs_token = cookies["HStoken"]
    
      sha_token = Digest::SHA1.hexdigest "#{hs_i}#{hs_ts}#{secret_key}"
      
      #puts "sha_token: #{sha_token}".green
      #puts "hs_token: #{hs_token}".red
    
      unless sha_token == hs_token
        ## Delete session
        session.delete(:id)
      
        ## Redirect the user to login page
        redirect_to new_session_path
      end
    end
    
  end
  
  ## This function will set a flash message depending up on the request type (ajax - xml http or direct http)
  ## example : store_flash_message("The message has been sent successfully", :success)
  def store_flash_message(message, type)
    if request.xhr?
      flash.now[type] = message
    else
      flash[type] = message
    end
  end
  
  def render_the_response(proc_code)
    begin
      proc_code.call
    rescue RequireLoginError
      respond_to do |format|
        format.html { redirect_to new_session_path }
        format.json { head :no_content }
      end
      return
    rescue PageNotFoundError
      respond_to do |format|
        format.html { render :text => "PageNotFoundError", :layout=>'api' }
        format.json { head :no_content }
      end
      return
    rescue Exception=>e
      respond_to do |format|
        format.html { render :text => e.message + "</br>" +  e.backtrace.join("</br>"), :layout=>'api' }
        format.json { head :no_content }
      end
      return
    end
    respond_to do |format|
      format.html { 
        redirect_to(@redirect_to_url, :notice => @notice_message) if @redirect_to_url
      }
      format.json { render :json =>  @json_string }
    end
    return
  end
  
  private
  
  def redirect_uri
    hootsuite_redirect_page_url(session_id: @user_session.id) if @user_session
  end
  
  def client_id
    if Rails.env == "production"
      client_id = "ARBO0LCIZVC3FTQMLNMGTFQF2EVD4UVT0425TFA0ZTCPHTYZ"
    else
      client_id = "IOMUMJQSZDLWTRYU4EQRPC3KY0NMDLGAJIQIKV4ZO2MTPMYZ"
    end
  end
  
  def client_secret
    if Rails.env == "production"
      client_secret = "1CMJ0R1XQZUPZSJLHZRRQ0SYFCHNK5HFYWS5KPNCLTW24SEX"
    else
      client_secret = "SEN4UAW5EGFWJB1OTXLKWYZLQHYT3ZKYSR23HCLK0WTANVMM"
    end
  end
  
  def response_type
    "code"
  end
  
  def grant_type
    "authorization_code"
  end
  
  helper_method :redirect_uri, :client_id, :client_secret, :response_type, :grant_type
  
  
end
