# frozen_string_literal: true

Rails.application.routes.draw do
  scope module: :web do
    root "home#index"

    get  "/auth/failure",         to: "auth#failure"
    get  "/auth/github/callback", to: "auth#create",  as: :auth_github_callback
    delete "/logout",             to: "auth#destroy", as: :logout

    resources :repositories, only: %i[index new create show] do
      resources :checks, only: %i[create show], module: :repositories
    end
  end

  namespace :api do
    resources :checks, only: :create
  end

  get "/up", to: "rails/health#show", as: :rails_health_check
end
