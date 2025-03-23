Rails.application.routes.draw do
  devise_for :users
  resources :users

  get "hello_world/index"

  get "up" => "rails/health#show", as: :rails_health_check

  get "/zoom/connect", to: "zoom#connect"
  get "/zoom/callback", to: "zoom#callback"

  root "users#index"
end
