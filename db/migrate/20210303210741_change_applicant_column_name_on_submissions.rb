class ChangeSubmitterColumnNameOnSubmissions < ActiveRecord::Migration[6.0]
  def change
    rename_column :grant_submission_submission_versions, :submitter_id, :submitter_id
  end
end
