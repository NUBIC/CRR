AudiologyRegistry::Application.routes.draw do
  namespace :admin do

    get '/' => "users#dashboard", :as=>:default
    resources :participants do
      collection do
        get :search
      end
      member do
        get   :enroll
        patch :verify
        patch :withdraw
        post  :consent_signature
      end
    end
    resources :studies do
      collection do
        get :search
      end
      member do
        patch :activate
        patch :deactivate
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
    resources :study_involvements do
      collection do
        get :study
      end
    end
    resources :contact_logs
    resources :relationships
    resources :users
    resources :searches do
      member do
        patch :request_data
        patch :release_data
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
      get :consent
      post :consent_signature
      patch :withdraw
    end
  end


  resources :accounts
  resources :account_sessions do
    collection do
      get :back_to_website
    end
  end

  resources :password_resets, :only => [ :create, :edit, :update ]
  get 'user_login' => 'account_sessions#new', :as => :public_login
  get 'user_logout' => 'account_sessions#destroy', :as => :public_logout
  get 'dashboard' => 'accounts#dashboard', :as => :dashboard
  get '/' =>  "account_sessions#new", :as => :public_root
  get 'back_to_website' => 'account_sessions#back_to_website', :as => :back_to_website
end
