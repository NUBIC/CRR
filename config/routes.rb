AudiologyRegistry::Application.routes.draw do

  resources :studies
  resources :participants
  
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
  resources :users

  get '/' =>  "participants#index"
end
