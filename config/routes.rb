# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root to: 'home#index'

  resources :grants do
    resources :grant_permissions, except: :show,                        controller: 'grant_permissions'
    resource  :duplicate,         only: %i[new create],                 controller: 'grants/duplicate'
    resource  :state,             only: :update,                        controller: 'grants/state'
    resources :forms,             only: %i[update edit update_fields],  controller: 'grant_submissions/forms' do
      member do
        put :update_fields
      end
    end

    resources :submissions,       except: %[new show],       controller: 'grant_submissions/submissions'

    get 'apply', to: 'grant_submissions/submissions#new', as: :apply
  end

  resources :reviews

  resources :users, only: %i[show index edit update]
end
