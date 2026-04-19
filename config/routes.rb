Rails.application.routes.draw do
  namespace :certificates do
    resources :root, only: [ :index, :show, :new ], param: :serial do
      resources :intermediate, only: [ :show, :new ], param: :serial do
        resources :server, only: [ :show, :new ], param: :serial
      end
    end
  end

  resources :certificates, only: [ :create ]
  resources :renew, only: [ :update ], param: :serial
  resources :delete, only: [ :destroy ], param: :serial

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "certificates/root#index"
end
