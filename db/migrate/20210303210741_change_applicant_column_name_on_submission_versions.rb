class ChangeApplicantColumnNameOnSubmissionVersions < ActiveRecord::Migration[6.0]
  def change
    rename_column :grant_submission_submission_versions, :applicant_id, :submitter_id
  end
end