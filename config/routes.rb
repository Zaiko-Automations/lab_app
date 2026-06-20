Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Dashboard/Admin routes
  root "medical_requests#index"
  resources :medical_requests, only: [:index, :show, :update] do
    member do
      post :validate
    end
  end

  # API Webhook routes
  namespace :api do
    namespace :v1 do
      resources :webhooks, only: [:create]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
