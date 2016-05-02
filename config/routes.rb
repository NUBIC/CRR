AudiologyRegistry::Application.routes.draw do
  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout' }

  # account_sessions controller (public)
  resources :account_sessions, only: [:new, :create, :destroy]
  get :back_to_website, controller: :account_sessions,  action: :back_to_website, as: :back_to_website
  get :user_login,      controller: :account_sessions,  action: :new,             as: :public_login
  get :user_logout,     controller: :account_sessions,  action: :destroy,         as: :public_logout

  # accounts controller (public)
  resources :accounts, only: [:create, :edit, :update] do
    collection do
      post :express_sign_up
    end
  end
  get :dashboard, controller: :accounts, action: :dashboard, as: :dashboard

  # participants controller (public)
  resources :participants, only: [:create, :show, :update] do
    member do
      get   :enroll
      get   :consent
      post  :consent_signature
    end

    collection do
      get :search
    end
  end

  # password_resets controller (public)
  resources :password_resets, only: [:create, :edit, :update ]

  # response_sets controller (public)
  resources :response_sets, only: [:create, :show, :edit, :update]

  # admin interface
  namespace :admin do
    root to: 'users#dashboard'
    get '/' => "users#dashboard", as: :default
    patch :set_maintenance_mode, to: 'admin#set_maintenance_mode'

    # answers controller
    resources :answers, only: [:new, :create, :show, :edit, :update, :destroy]

    # consents controller
    resources :consents do
      member do
        patch :activate
        patch :deactivate
      end
    end

    # contact logs controller
    resources :contact_logs, except: [:show, :index]

    # email notifications controller
    resources :email_notifications, only: [:index, :show, :edit, :update] do
      member do
        patch :activate
        patch :deactivate
      end
    end

    # participants controller
    resources :participants, except: [:destroy] do
      collection do
        get :search
        get :global
      end
      member do
        get   :enroll
        patch :verify
        patch :withdraw
        post  :consent_signature
      end
    end

    # questions controller
    resources :questions, except: :index do
      collection do
        get :search
      end
    end

    # relationships controller
    resources :relationships, except: [:show]

    # response_sets controller
    resources :response_sets, only: [:index, :new, :create, :edit, :update, :destroy] do
      member do
        patch :load_from_file
      end
    end

    # search_condition_groups controller
    resources :search_condition_groups, only: [:create, :update, :destroy]

    # search_conditions controller
    resources :search_conditions, only: [:new, :create, :show, :edit, :update, :destroy] do
      collection do
        get :values
      end
    end

    # searches controller
    resources :searches do
      member do
        patch :request_data
        patch :release_data
      end
    end

    # sections controller
    resources :sections, only: [:new, :create, :show, :edit, :update, :destroy]

    # studies controller
    resources :studies do
      collection do
        get :search
      end
      member do
        patch :activate
        patch :deactivate
      end
    end

    # study involvments controller
    resources :study_involvements, only: [:new, :create, :edit, :update, :destroy]

    # surveys controller
    resources :surveys do
      member do
        patch :activate
        patch :deactivate
        get   :preview
      end
    end

    # users controller
    resources :users, only: [:index, :new, :create, :edit, :update, :destroy]
  end
  get '/' =>  "account_sessions#new", :as => :public_root
end
