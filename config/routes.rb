Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Define the root path
  root 'dashboard#index'
  
  # Dashboard
  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/stats', to: 'dashboard#stats'
  
  # Main resources
  resources :customers do
    resources :vehicles, except: [:index]
    member do
      get :vehicles
    end
  end
  
  resources :vehicles, only: [:index, :show, :edit, :update]
  
  resources :quotes do
    member do
      patch :approve
      patch :reject
      get :print
    end
    resources :quote_items, except: [:index, :show]
  end
  
  resources :work_orders do
    member do
      patch :start
      patch :complete
      patch :cancel
      get :print
    end
    resources :work_order_items, except: [:index, :show]
  end
  
  resources :departments do
    member do
      patch :activate
      patch :deactivate
    end
  end
  
  resources :service_types do
    member do
      patch :activate
      patch :deactivate
    end
  end
  
  resources :vehicle_brands, only: [:index, :show, :create] do
    resources :vehicle_models, except: [:index]
  end
  
  resources :vehicle_models, only: [:index, :show, :create] do
    collection do
      get :by_brand
    end
  end
  
  resources :vehicle_statuses, only: [:index, :show, :create, :update]
  
  # Admin routes
  namespace :admin do
    resources :users do
      member do
        patch :activate
        patch :deactivate
      end
    end
  end
  
  # API routes for AJAX requests
  namespace :api do
    namespace :v1 do
      resources :vehicle_lookup, only: [] do
        collection do
          get :lookup_by_plate
        end
      end
    end
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
