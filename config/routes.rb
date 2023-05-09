# frozen_string_literal: true
# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  devise_for :registered_users, controllers: {
                                  confirmations:  'registered_users/confirmations',
                                  passwords:      'registered_users/passwords',
                                  registrations:  'registered_users/registrations',
                                  sessions:       'registered_users/sessions'
                                }

  devise_for :saml_users, path: 'users', controllers: { saml_sessions: 'saml_sessions' }

  resources :users, only: %i[index edit update]

  root to: 'home#index'

  resources :login, only: %i[index]

  resources :banners, except: %i[show]

  resources :documentation, only: %i[index] do
    get 'release', to: 'documentation/release#index', on: :collection
  end


  resources :grant_creator_requests do
    resource :review, only: %i[show update], controller: 'grant_creator_requests/review', on: :member
  end

  resources :grants do
    resources :grant_permissions, except: :show, controller: 'grant_permissions' do
      get :users_query, on: :collection, to: 'grant_permissions/users_query#index', as: :users_query
    end

    resource  :duplicate,         only: %i[new create],     controller: 'grants/duplicate'

    resource  :state,             only: %i[publish draft],  controller: 'grants/state' do
      get 'publish',  on: :member
      get 'draft',    on: :member
    end

    resources :reviews,           only: :index,             controller: 'grants/reviews' do
      get 'reminders',            to: 'grants/reviews/reminders#index', on: :collection
    end

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
      resources 'applicants',     only: %i[index create destroy], controller: 'grant_submissions/submissions/submission_applicants'

      collection do
        get 'export',             only: :index, to: 'grant_submissions/submissions/export#index'
      end

      member do
        patch 'unsubmit', to: 'grant_submissions/submissions/unsubmit#update'
        patch 'award',    to: 'grant_submissions/submissions/award#update'
      end

      resources :reviews,         except: %i[new],  controller: 'grant_submissions/submissions/reviews' do
        delete 'opt_out',         to: 'grant_submissions/submissions/reviews/opt_out#destroy', on: :member
      end
    end

    resources :reviewers,         only: %i[index create destroy], controller: 'grant_reviewers' do
      collection do
        post      'invite',       to: 'grant_reviewers/invitations#create'
        resources 'invitations',  only: %i[index update destroy], controller: 'grant_reviewers/invitations' do
          collection do
            resources :reminders, only: %i[index show], as: 'invitation_reminders', controller: 'grant_reviewers/invitations/reminders'
          end
        end
      end
    end

    resource :panel,              only: %i[show edit update], on: :member, controller: 'panels' do
      resources :submissions,     only: %i[index show], controller: 'panels/submissions' do
        resources :reviews,       only: %i[index show], controller: 'panels/submissions/reviews'
      end
    end

    get 'apply', to: 'grant_submissions/submissions#new', as: :apply
  end

  resource :profile, only: %i[show update] do
    resources :grants,      only: :index, controller: 'profiles/grants'
    resources :reviews,     only: :index, controller: 'profiles/reviews'
    resources :submissions, only: :index, controller: 'profiles/submissions'
    resources :panels,      only: :index, controller: 'profiles/panels'
  end
end
