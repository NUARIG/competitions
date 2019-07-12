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

    get 'apply', to: 'grant_submissions/submissions#new', as: :apply
  end

  resources :reviews

  resources :users, only: %i[show index edit update]

  # opt-in saml_authenticatable
  devise_scope :user do
    scope "users", controller: 'devise/saml_sessions' do
      get :new, path: "saml/sign_in", as: :new_user_sso_session
      post :create, path: "saml/auth", as: :user_sso_session
      get :destroy, path: "sign_out", as: :destroy_user_sso_session
      get :metadata, path: "saml/metadata", as: :metadata_user_sso_session
      match :idp_sign_out, path: "saml/idp_sign_out", via: [:get, :post]
    end
  end
end
