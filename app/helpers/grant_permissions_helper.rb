# frozen_string_literal: true

module GrantPermissionsHelper
  ROLE_DESCRIPTIONS = { 'Admin': 'Delete or edit this grant and its submissions and reviews.',
                        'Editor': 'Edit this grant and its submissions and reviews.',
                        'Viewer': 'View this grant\'s submissions and reviews.' }.freeze

  def grant_permission_role_select_options
    GrantPermission::ROLES.values.map do |role|
      ["#{role.capitalize} - #{ROLE_DESCRIPTIONS[role.capitalize.to_sym]}", role]
    end
  end

  def admin_submission_notification_emails(grant:)
    grant.grant_permissions
         .with_user
         .where(submission_notification: true)
         .map { |permission| permission.user.email }
  end

  def role_can_be_deleted?(user_permission:, grant_admins:)
    return true unless user_permission.role == GrantPermission::ROLES[:admin]

    grant_admins.one? ? false : true
  end

  def render_turbo_stream_grant_permission(grant:, permission:)
    turbo_stream.replace dom_id(permission), partial: 'grant_permission',
                                             locals: { grant: grant, grant_permission: permission }
  end
end
