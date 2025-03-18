Rails.application.routes.draw do
  devise_for :users
  resources :users

  get "hello_world/index"

  get "up" => "rails/health#show", as: :rails_health_check

  root "users#index"
end
