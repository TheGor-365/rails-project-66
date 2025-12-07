Rails.application.routes.draw do
  root "home#index"

  match '/auth/:provider/callback', to: 'sessions#create', via: %i[get post]
  delete '/logout', to: 'sessions#destroy', as: :logout

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get '/sentry-test', to: proc { raise "Sentry test error" }
end
