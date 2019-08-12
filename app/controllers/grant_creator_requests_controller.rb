# frozen_string_literal: true

class GrantCreatorRequestsController < ApplicationController
  def new
    @grant_creator_request = GrantCreatorRequest.new
    authorize @grant_creator_request
  end

  def create

  end

  def show

  end

  def update

  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to(request.referrer || profile_path)
  end
end
