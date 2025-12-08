# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"

  post "/auth/github", to: "sessions#create"
  get "/auth/github/callback", to: "sessions#create", as: :auth_github_callback
  delete "/logout", to: "sessions#destroy", as: :logout

  resources :repositories, only: %i[index new create show] do
    resources :checks, only: %i[create show], module: :repositories
  end

  get "up", to: "rails/health#show", as: :rails_health_check
end
