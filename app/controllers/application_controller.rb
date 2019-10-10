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
end
