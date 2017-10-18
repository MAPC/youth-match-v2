require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'sessions' }
  get 'travel_time/get'
  resources :position_imports, only: [:create]

  scope 'api' do
    resources :offers
    resources :applicants, only: [:index, :show, :update]

    resources :positions, only: [:index, :show, :update, :owned] do
      get 'owned', to: 'positions#owned', on: :collection
      resources :applicants
      resources :requisitions
    end
    resources :users, only: [:create, :update, :show, :index] do
      resources :positions
    end
    resources :requisitions, only: [:update, :show]
    resources :outgoing_messages, only: [:create, :new, :index, :show]
    resources :lottery_numbers, only: [:create]
    resources :travel_time_scores, only: [:create]
    resources :preference_scores, only: [:create]
  end

  resources :applicant_imports, only: [:create]
  resources :update_icims, only: [:create]

  root to: 'offers#index'

  get 'offers/accept'
  get 'offers/decline'

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
