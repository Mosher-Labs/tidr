Rails.application.routes.draw do
  devise_for :users
  resources :users

  get "hello_world/index"

  get "up" => "rails/health#show", as: :rails_health_check

  get "/zoom/connect", to: "zoom#connect"
  get "/zoom/callback", to: "zoom#callback"
  post "/zoom/disconnect", to: "users#disconnect_zoom"

  get "/auth/calendly", to: "calendly#connect"
  get "/auth/calendly/callback", to: "calendly#callback"

  root "users#index"
end
