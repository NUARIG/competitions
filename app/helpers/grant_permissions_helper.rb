# frozen_string_literal: true

module GrantPermissionsHelper
  def grant_permission_role_select_options
    GrantPermission::ROLES.values.map{ |permission| [permission.capitalize, permission]}
  end

  def admin_submission_notification_emails(grant:)
    grant.grant_permissions
         .with_user
         .where(submission_notification: true)
         .map{ |permission| permission.user.email }
  end
end
