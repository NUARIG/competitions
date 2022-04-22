# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_paper_trail_whodunnit, :audit_action
  before_action :configure_permitted_parameters_for_devise_methods, if: :devise_controller?

  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protect_from_forgery prepend: true, with: :exception
  # protect_from_forgery with: :null_session



  def user_for_paper_trail
    current_user&.id || 'Unauthenticated user'
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:alert] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to(request.referrer || root_path)
  end

  def audit_action
    if current_user
      AuditAction.create(user:       current_user,
                         controller: controller_name,
                         action:     request.path,
                         browser:    request.env['HTTP_USER_AGENT'],
                         params:     params.except(:utf8, :_method, :authenticity_token, :controller, :action))
    end
  end

  # Devise methods
  def authenticate_user!
    unless user_signed_in?
      store_user_location!
      flash[:alert] = 'You need to sign in or sign up before continuing.'
      redirect_to login_index_url
    end
  end

  def user_signed_in?
    saml_user_signed_in? || registered_user_signed_in?
  end

  def current_user
    current_saml_user || current_registered_user
  end

  helper_method :current_user
  helper_method :user_signed_in?

  def store_user_location!
    store_location_for(:registered_user, request.fullpath)
    store_location_for(:saml_user, request.fullpath)
  end

  protected

    # Permitted parameters for users in devise methods.
    def configure_permitted_parameters_for_devise_methods
      devise_parameter_sanitizer.permit(:sign_in) do |user_params|
        user_params.permit(:uid, :password)
      end

      devise_parameter_sanitizer.permit(:sign_up) do |user_params|
        user_params.permit(:email, :password, :password_confirmation, :last_name, :first_name, :era_commons)
      end

      devise_parameter_sanitizer.permit(:account_update) do |user_params|
        user_params.permit(:current_password, :password, :password_confirmation)
      end
    end

    def redirect_logged_in_user_to_root
      flash[:notice] = 'You are already logged in.'
      redirect_to root_path
    end
end
