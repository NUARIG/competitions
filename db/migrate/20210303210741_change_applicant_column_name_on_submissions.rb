class ChangeApplicantColumnNameOnSubmissions < ActiveRecord::Migration[6.0]
  def change
    rename_column :grant_submission_submission_versions, :applicant_id, :submitter_id
    rename_index :grant_submission_submission_versions, 'index_gs_submission_v_on_grant_id_applicant_it', 'index_gs_submission_v_on_grant_id_submitter_it'
  end
end
