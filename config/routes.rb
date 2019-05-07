# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root to: 'home#index'

  resources :grants do
    resources :grant_users, except: :show,               controller: 'grants/grant_users'
    resource  :duplicate,   only: %i[new create],        controller: 'grants/duplicate'
    resource  :state,       only: :update,               controller: 'grants/state'
  end

  resources :users, only: %i[show index edit update]
end
