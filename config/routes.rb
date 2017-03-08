Rails.application.routes.draw do
  get 'travel_time/get'

  resources :applicant_imports, only: [:create]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
