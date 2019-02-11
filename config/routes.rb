Rails.application.routes.draw do
  resources :questions
  resources :fields
  resources :grants
  resources :users
  resources :organizations
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
