AudiologyRegistry::Application.routes.draw do

  resources :studies
  resources :participants
  get '/' =>  "participants#index"
end
