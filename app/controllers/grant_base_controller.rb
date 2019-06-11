class GrantBaseController < ApplicationController
  def pundit_user
    GrantContext.new(current_user, @grant)
  end
end
