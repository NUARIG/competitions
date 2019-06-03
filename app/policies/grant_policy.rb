# frozen_string_literal: true

class GrantPolicy < AccessPolicy
  def index?
    user.present?
  end

  def show?
    case record.published?
    when true
      index?
    else
      grant_viewer_access?
    end
  end

  def create?
    organization_admin_access?
  end

  def new?
    create?
  end

  def update?
    grant_editor_access?
  end

  def edit?
    update?
  end

  def destroy?
    grant_admin_access?
  end

  # Grant Access
  def grant_admin_access?
    check_grant_access(%w[admin])
  end

  def grant_editor_access?
    check_grant_access(%w[admin editor])
  end

  def grant_viewer_access?
    check_grant_access(%w[admin editor viewer])
  end

  def check_grant_access(role_list)
    user.id.in?(
      GrantPermission.where(role: role_list)
      .where(grant: grant)
      .pluck(:user_id)
    )
  end

  private

  def grant
    record
  end
end
