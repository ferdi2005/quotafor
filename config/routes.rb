Rails.application.routes.draw do
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

  root "dashboard#index"
  devise_for :users
  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end

  unauthenticated do
    root "devise/sessions#new", as: :unauthenticated_root
  end

  resources :customers do
    resources :appointments, only: %i[new create edit update destroy]
    resources :contact_calls, only: %i[new create edit update destroy]
    resources :customer_objectives, only: %i[new create edit update destroy]
    resources :customer_timeline_notes, only: %i[new create destroy]
  end
  resources :in_app_notifications, only: %i[index] do
    member do
      patch :mark_as_read
    end
  end
  resources :recurring_activities
  resources :calendar_events, only: [ :index ]
  get "calendar/feed/:token", to: "calendar_feeds#show", as: :calendar_feed, defaults: { format: :ics }
  post "calendar/regenerate_token", to: "calendar_feeds#regenerate_token", as: :calendar_regenerate_token

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "dashboard", to: "dashboard#index"
end
