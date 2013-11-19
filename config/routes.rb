AudiologyRegistry::Application.routes.draw do
  namespace :admin do

    get '/' => "users#dashboard", :as=>:default
    resources :participants do
      collection do
        get :search
      end
    end
    resources :studies do
      collection do
        get :search
      end
    end
    resources :sections
    resources :questions do
      collection do
        get :search
      end
    end
    resources :answers
    resources :surveys do
      member do
        patch :activate
        patch :deactivate
        get   :preview
      end
    end
    resources :response_sets
    resources :study_involvements
    resources :contact_logs
    resources :relationships
    resources :users
    resources :searches do
      member do
        patch :request
        patch :release
      end
    end
    resources :search_condition_groups
    resources :search_conditions
    resources :consents do
      member do
        patch :activate
        patch :deactivate
      end
    end
  end

  resources :response_sets

  resources :participants, :except=>["index"] do
    collection do
      get :search
    end
    member do
      get :enroll
      post :consent_signature
      patch :withdraw
    end
  end


  resources :accounts
  resources :account_sessions
  get 'user_login' => 'account_sessions#new', :as => :public_login
  get 'user_logout' => 'account_sessions#destroy', :as => :public_logout
  get 'dashboard' => 'accounts#dashboard', :as => :dashboard

  get '/' =>  "account_sessions#new"
end
