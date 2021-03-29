class CreateGrantSubmissionSubmissionApplicants < ActiveRecord::Migration[6.0]
  def change
    create_table :grant_submission_submission_applicants do |t|
      t.references :grant_submission_submission, index: { name: 'i_gsa_on_grant_submission_submission_id' }
      t.references :user
      t.string     :role
      t.datetime   :deleted_at

      t.timestamps
    end
  end
end
