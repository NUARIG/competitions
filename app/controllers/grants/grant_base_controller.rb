module Grants
  class GrantBaseController < ApplicationController

    include Pundit

    def set_org
      @grant = Grant.find(params[:grant_id])
      raise Pundit::NotAuthorizedError if @grant.nil?
    end

    def pundit_user
      GrantContext.new(current_user, @grant)
    end
  end
end