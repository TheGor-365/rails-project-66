Rails.application.routes.draw do
  root "home#index"

  resources :repositories, only: %i[index new create]

  match '/auth/:provider/callback', to: 'sessions#create', via: %i[get post]
  delete '/logout', to: 'sessions#destroy', as: :logout

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
