Foursquare::Application.routes.draw do
  
  root :to => 'sessions#new'
  resources :sessions, :only=>[:new, :create, :destroy]
  
  ## ------------------
  ## Appplication URLS
  ## ------------------
  match 'hootsuite/landing_page' => 'hootsuite/main#index', :as => :hootsuite_landing_page
  match 'hootsuite/authenticated' => 'hootsuite/main#authenticated', :as => :hootsuite_authenticated
  match 'hootsuite/redirect' => 'sessions#create', :as => :hootsuite_redirect_page
  
  ## --------
  ## API URLS
  ## --------

  ## Projects
  match 'api/managed_venues'            => 'api/managed_venues#index', :as => :api_managed_venues
  match 'api/managed_venues/:id'        => 'api/managed_venues#show', :as => :api_managed_venue
  
end
