class ChangeSubmittedAtToUserUpdatedAt < ActiveRecord::Migration[5.2]
  def up
    rename_column :grant_submission_submissions, :submitted_at, :user_updated_at
  end

  def down
    rename_column :grant_submission_submissions, :user_updated_at, :submitted_at
  end
end
