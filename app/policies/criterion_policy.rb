# frozen_string_literal: true

class CriterionPolicy < GrantPolicy
  def index?
    grant_viewer_access?
  end

  def edit?
    super
  end

  def update
    edit?
  end

  private

  def criterion
    record
  end

end
