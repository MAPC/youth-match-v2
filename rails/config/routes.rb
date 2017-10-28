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

    resources :picks, only: [:show, :index, :update, :create, :destroy]
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
    resources :offer_emails, only: [:create]
    match "expire-lottery-status" => proc { [200, {"Content-Type" => "text/plain"}, [Sidekiq::Queue.new('expire_lottery').size < 1 ? "Empty" : "Active" ]] }, via: :get
    match "match-lottery-status" => proc { [200, {"Content-Type" => "text/plain"}, [Sidekiq::Queue.new('match_lottery').size < 1 ? "Empty" : "Active" ]] }, via: :get
    match "workers-status" => proc { [200, {"Content-Type" => "text/plain"}, [Sidekiq::Workers.new.size < 1 ? "Empty" : "Active" ]] }, via: :get
    Sidekiq::Workers.new
  end

  root to: 'offers#index'

  get 'offers/accept'
  get 'offers/decline'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
