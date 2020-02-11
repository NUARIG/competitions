class AddStateColumnToSubmissions < ActiveRecord::Migration[5.2]
  def up
    add_column :grant_submission_submissions, :state, :string
    GrantSubmission::Submission.update_all(state: 'submitted')
    change_column_null :grant_submission_submissions, :state, false
    add_column :grant_submission_submissions, :submitted_at, :datetime
    GrantSubmission::Submission.update_all("submitted_at=created_at")
  end

  def down
    remove_column :grant_submission_submissions, :state
    remove_column :grant_submission_submissions, :submitted_at
  end
end
