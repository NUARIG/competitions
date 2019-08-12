# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root to: 'home#index'

  resources :grants do
    resources :grant_permissions, except: :show,        controller: 'grant_permissions'
    resource  :duplicate,         only: %i[new create], controller: 'grants/duplicate'
    resource  :state,             only: :update,        controller: 'grants/state'
    resources :reviews,           only: :index,         controller: 'grants/reviews'
    member do
      get   'criteria',           to: 'grants/criteria#index',   as: :criteria
      patch 'criteria/update',    to: 'grants/criteria#update',  as: :update_criteria
    end
    resources :forms,             only: %i[update edit update_fields],  controller: 'grant_submissions/forms' do
      member do
        put :update_fields
      end
    end
    resources :submissions,       except: %i[new],  controller: 'grant_submissions/submissions' do
      resources :reviews,         except: %i[new],  controller: 'grant_submissions/submissions/reviews' do
        delete 'opt_out',         to: 'grant_submissions/submissions/reviews/opt_out#destroy', on: :member
      end
    end
    resources :reviewers,         only: %i[index create destroy], controller: 'grant_reviewers'

    get 'apply', to: 'grant_submissions/submissions#new', as: :apply
  end

  resource :profile, only: %i[show update]
  resources :grant_creator_requests

end
