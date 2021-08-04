class CreateGrantSubmissionSubmissionApplicantVersions < ActiveRecord::Migration[6.0]
  def change
    create_table :grant_submission_submission_applicant_versions do |t|
      t.string   :item_type,  null: false
      t.integer  :item_id,    null: false
      t.integer  :grant_submission_submission_id,   null: false
      t.integer  :applicant_id,    null: false
      t.string   :event,      null: false
      t.integer  :whodunnit # user id
      t.text     :object
      t.datetime :created_at, null: false
    end

    add_index :grant_submission_submission_applicant_versions, [:item_id], name: 'index_gs_submission_applicant_v_on_item_id'
    add_index :grant_submission_submission_applicant_versions, [:grant_submission_submission_id],  name: 'index_gs_submission_applicant_v_on_submission_id'
    add_index :grant_submission_submission_applicant_versions, [:applicant_id], name: 'index_gs_submission_applicant_v_on_applicant_id'
    add_index :grant_submission_submission_applicant_versions, [:whodunnit], name: 'index_gs_submission_applicant_v_on_whodunnit'
  end
end
