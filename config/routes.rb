# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root to: 'home#index'

  resources :grants do
    resources :grant_permissions, except: :show,                        controller: 'grant_permissions'
    resource  :duplicate,         only: %i[new create],                 controller: 'grants/duplicate'
    resource  :state,             only: :update,                        controller: 'grants/state'
    member do
      get   'criteria',        to: 'grants/criteria#index',  as: :criteria
      patch 'criteria/update', to: 'grants/criteria#update', as: :update_criteria
    end
    resources :forms,             only: %i[update edit update_fields],  controller: 'grant_submissions/forms' do
      member do
        put :update_fields
      end
    end

    resources :submissions,       except: %[new show],       controller: 'grant_submissions/submissions'

    # member do
    #   patch :update_criteria
    # end

    # get 'criteria', to: 'criteria#index'
    get 'apply', to: 'grant_submissions/submissions#new', as: :apply
  end

  resources :reviews

  resources :users, only: %i[show index edit update]
end
