# frozen_string_literal: true

class GrantSubmission::FormPolicy < GrantPolicy

  def update?
    super
  end

  def edit?
    grant_viewer_access?
  end

  def update_fields?
    grant_editor_access?
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
