# frozen_string_literal: true

class GrantSubmission::FormPolicy < GrantPolicy

  def update?
    super
  end

  def edit?
    update?
  end

  def update_fields?
    organization_admin_access? || grant_editor_access?
  end

  def export?
    update_fields?
  end

  def import?
    update_fields?
  end

  private

  def form
    record
  end

  def grant
    form.grant
  end
end
