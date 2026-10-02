Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "uploaded_files#index"

  # First-run setup (creates the first admin account)
  resource :setup, only: [ :new, :create ]

  # Authentication routes
  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#authenticate"
  get "/auth/:provider/callback", to: "sessions#create"
  post "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  delete "/logout", to: "sessions#destroy", as: :logout
  patch "/theme_preference", to: "theme_preferences#update", as: :theme_preference

  resource :entra_setting, only: [ :edit, :update ]
  resource :storage_setting, only: [ :edit, :update ]

  resources :uploaded_files, param: :upload_uuid
end
