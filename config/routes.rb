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
      patch :request
      patch :process 
    end
  end

  get '/' =>  "participants#index"
end
