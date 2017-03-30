Rails.application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'sessions' }
  get 'travel_time/get'
  resources :position_imports, only: [:create]

  scope 'api' do
    resources :rehire_sites, only: [:get_uniq_sites, :index, :update] do
      get 'get_uniq_sites', to: 'rehire_sites#get_uniq_sites', on: :collection
    end

    resources :offers
    resources :applicants, only: [:index, :show, :update]
    resources :positions, only: [:index, :show, :update, :owned] do
      get 'owned', to: 'positions#owned', on: :collection
      resources :applicants
    end
    resources :users, only: [:show, :index]
    resources :requisitions, only: [:update]
  end

  resources :applicant_imports, only: [:create]
  root to: 'offers#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
