require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'sessions' }

  scope 'api' do
    resources :offers
    resources :applicants, only: [:index, :show, :update]

    resources :positions, only: [:index, :show, :update, :owned] do
      get 'owned', to: 'positions#owned', on: :collection
      resources :applicants
      resources :requisitions
      resources :selections
      resources :picks
    end
    resources :users, only: [:create, :update, :show, :index] do
      resources :positions
    end
    resources :requisitions, only: [:update, :show]
    resources :outgoing_messages, only: [:create, :new, :index, :show]
    resources :lottery_numbers, only: [:create]
    resources :travel_time_scores, only: [:create]
    resources :preference_scores, only: [:create]
    resources :matches, only: [:create]
    resources :lottery_activated_statuses, only: [:create]
    resources :applicant_imports, only: [:create]
    resources :update_icims, only: [:create]
    resources :position_imports, only: [:create]
    resources :password_resets, only: [:create]
  end

  root to: 'offers#index'

  get 'offers/accept'
  get 'offers/decline'

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
