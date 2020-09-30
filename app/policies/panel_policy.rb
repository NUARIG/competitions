# frozen_string_literal: true

class PanelPolicy < GrantPolicy
  def show?
    user.present? && grant_viewer_access? || user_is_grant_reviewer?
  end

  def edit?
    user.present? && grant_editor_access?
  end

  private

  def panel
    record
  end

  def grant
    panel.grant
  end
end
