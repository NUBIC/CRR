AudiologyRegistry::Application.routes.draw do

  resources :studies
  resources :participants
  
  resources :surveys do 
    member do 
      put :activate
      put :deactivate
    end
  end
  resources :sections
  resources :questions
  resources :answers
  resources :response_sets

  get '/' =>  "participants#index"
end
