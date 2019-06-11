# frozen_string_literal: true

# TODO: This should never get hit because the controller authorizes against grant.
class Grant::StatePolicy < GrantPolicy

  def update?
    super
  end

  private

  def grant
    record
  end
end
