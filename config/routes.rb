# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root to: 'grants#index'

  resources :grants do
    resources :questions, only: %i[index edit update], controller: 'grants/questions'
    resources :grant_users, except: :show, controller: 'grants/grant_users'
  end

  resources :questions, except: %i[show create]

  resources :organizations
  resources :users, only: %i[show index edit update]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
