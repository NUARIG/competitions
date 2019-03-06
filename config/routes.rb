Rails.application.routes.draw do
  devise_for :users

  root to: 'grants#index'

  resources :fields
  resources :grants do
    resources :questions
    resources :grant_users, except: :show
  end

  resources :organizations
  resources :users, only: %i[show index edit update]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
