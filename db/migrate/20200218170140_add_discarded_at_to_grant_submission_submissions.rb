class AddDiscardedAtToGrantSubmissionSubmissions < ActiveRecord::Migration[5.2]
  def up
    add_column :grant_submission_submissions, :discarded_at, :datetime
    add_index :grant_submission_submissions, :discarded_at
  end

  def down
    remove_index :grant_submission_submissions, :discarded_at
    remove_column :grant_submission_submissions, :discarded_at, :datetime
  end
end
