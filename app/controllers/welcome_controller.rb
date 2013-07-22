class WelcomeController < ApplicationController
  
  def home
    render :layout=>"hootsuite"
  end
  
  def dc_receiver
    render :layout=>"dc_receiver"
  end
  
end
