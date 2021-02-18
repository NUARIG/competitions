class AddSubmissionNotificationToGrantPermissions < ActiveRecord::Migration[6.0]
  def up
    add_column :grant_permissions, :submission_notification, :boolean, default: false
    GrantPermission.update_all(submission_notification: false)
    change_column_null :grant_permissions, :submission_notification, false
  end

  def down
    remove_column :grant_permissions, :submission_notification
  end
end
