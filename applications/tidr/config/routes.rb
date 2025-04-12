Rails.application.routes.draw do
  devise_for :users
  resources :users

  get "up" => "rails/health#show", as: :rails_health_check

  get "/auth/calendly", to: "calendly#connect"
  get "/auth/calendly/callback", to: "calendly#callback"
  post "/calendly/disconnect", to: "users#disconnect_calendly"

  get "/oauth/dropbox/callback", to: "oauth#dropbox"
  post "/dropbox/disconnect", to: "users#disconnect_dropbox"

  get "/zoom/connect", to: "zoom#connect"
  get "/zoom/callback", to: "zoom#callback"
  post "/zoom/disconnect", to: "users#disconnect_zoom"
  post "webhooks/zoom" => "webhooks#zoom"

  root "users#index"
end
