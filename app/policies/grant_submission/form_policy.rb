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
    # clean_record_from_collection.grant
  end

  # def confirm_organization
  #   user.present? &&
  #     clean_record_from_collection.grant.organization == user.organization
  # end
end
