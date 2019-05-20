# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root to: 'home#index'

  resources :grants do
    resources :grant_permissions, except: :show,             controller: 'grants/grant_permissions'
    resource  :duplicate,         only: %i[new create],      controller: 'grants/duplicate'
    resource  :state,             only: :update,             controller: 'grants/state'
    resources :forms,             except: %i[index destroy], controller: 'grants/forms' do
      member do
        put :update_fields
      end
    end
    #resources :submissions,       only: :index,              controller: 'grants/submissions'
    resources :submissions,       controller: 'grants/submissions'
    # member do
    #   get 'apply', to: 'submissions#new'
    # end
  end


  resources :users, only: %i[show index edit update]
end
