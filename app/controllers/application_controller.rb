# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  include Pagy::Backend

  before_action :authenticate_user!, :set_paper_trail_whodunnit, :audit_action

  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protect_from_forgery with: :exception

  def user_for_paper_trail
    user_signed_in? ? current_user.id : 'Unauthenticated user'
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
  # def authenticate_user!
  #   store_location_for(:registered_user, request.original_url)
  #   store_location_for(:saml_user, request.original_url)
  #   if (!saml_user_signed_in? && !registered_user_signed_in?)
  #     flash[:alert] = 'You need to sign in or sign up before continuing.'
  #     redirect_to login_url
  #   end
  # end

  def user_signed_in?
    saml_user_signed_in? || registered_user_signed_in?
  end

  def current_user
    current_saml_user  || current_registered_user
  end

  # def user_type?(resource, user_class)
  #   resource.class == user_class
  # end

  helper_method :current_user
  helper_method :user_signed_in?
end
