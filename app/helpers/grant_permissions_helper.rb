# frozen_string_literal: true

module GrantPermissionsHelper
  ROLE_DESCRIPTIONS = { 'Admin':  'Delete or edit this grant and its submissions and reviews.',
                        'Editor': 'Edit this grant and its submissions and reviews.',
                        'Viewer': 'View this grant\'s submissions and reviews.' }


  def grant_permission_role_select_options
    GrantPermission::ROLES.values.map{ |role| ["#{role.capitalize} - #{ROLE_DESCRIPTIONS[role.capitalize.to_sym]}", role] }
  end

  def admin_submission_notification_emails(grant:)
    grant.grant_permissions
         .with_user
         .where(submission_notification: true)
         .map{ |permission| permission.user.email }
  end
end
