# frozen_string_literal: true

class PanelPolicy < ApplicationPolicy
  include GrantRoleAccess

  def show?
    user.present? && (user_is_grant_reviewer? || grant_viewer_access?)
  end

  def edit?
    user.present? && grant_editor_access?
  end

  def update?
    edit?
  end

  private

  def panel
    record
  end

  def grant
    record.grant
  end
end
