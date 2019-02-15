Rails.application.routes.draw do
  devise_for :users

  root to: 'grants#index'

  resources :fields
  resources :grants do
    resources :questions
  end
  resources :users
  resources :organizations
  resources :users, only: %i[index edit update]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
