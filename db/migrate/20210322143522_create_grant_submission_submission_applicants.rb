class CreateGrantSubmissionSubmissionApplicants < ActiveRecord::Migration[6.0]
  def change
    create_table :grant_submission_submission_applicants do |t|
      t.references :grant_submission_submission,  foreign_key: true,
                                                  null: false,
                                                  index: { name: 'i_gssa_on_grant_submission_submission_id' }
      t.bigint     :applicant_id,  null: false
      t.datetime   :deleted_at

      t.timestamps
    end
    add_index :grant_submission_submission_applicants, [:applicant_id]
  end
end
