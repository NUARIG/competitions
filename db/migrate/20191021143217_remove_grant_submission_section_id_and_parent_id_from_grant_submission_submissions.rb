class RemoveGrantSubmissionSectionIdAndParentIdFromGrantSubmissionSubmissions < ActiveRecord::Migration[5.2]
  def up
    remove_column :grant_submission_submissions, :grant_submission_section_id
    remove_column :grant_submission_submissions, :parent_id
  end

  def down
    add_column :grant_submission_submissions, :grant_submission_section_id, :bigint
    add_column :grant_submission_submissions, :parent_id, :bigint
  end
end
