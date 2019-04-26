# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root to: 'home#index'

  resources :grants do
    resources :questions,   only: %i[index edit update], controller: 'grants/questions'
    resources :grant_users, except: :show,               controller: 'grants/grant_users'
    resource  :duplicate,   only: %i[new create],        controller: 'grants/duplicate'
    resources :submissions,                              controller: 'grants/submissions'
    resource  :state,       only: :update,               controller: 'grants/state'
  end

  resources :users, only: %i[show index edit update]
end
