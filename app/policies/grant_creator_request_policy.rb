class GrantCreatorRequestPolicy < ApplicationPolicy
  def new?
    user.present?
  end
end
