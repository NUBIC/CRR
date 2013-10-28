AudiologyRegistry::Application.routes.draw do

  resources :studies
  resources :participants do 
    collection do 
      get :search
    end
  end
  
  resources :surveys do 
    member do 
      patch :activate
      patch :deactivate
    end
  end
  resources :sections
  resources :questions
  resources :answers
  resources :response_sets
  resources :study_involvements
  resources :contact_logs
  resources :relationships
  resources :users
  resources :searches do 
    member do 
      patch :request_data
      patch :release_data
    end
  end

  resources :accounts
  resources :account_sessions
  get 'login' => 'account_sessions#new', :as => :login
  get 'logout' => 'account_sessions#destroy', :as => :logout
  get 'dashboard' => 'accounts#index', :as => :dashboard

  resources :welcome

  get '/' =>  "welcome#index"
end
