Rails.application.routes.draw do
  devise_for :users

  root to: 'grants#index'

  resources :grants do
    resources :questions
  end

  resources :organizations
  resources :users, only: %i[show index edit update]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
