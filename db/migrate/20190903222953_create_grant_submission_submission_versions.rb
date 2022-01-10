class CreateGrantSubmissionSubmissionVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :grant_submission_submission_versions do |t|
      t.string   :item_type,   null: false
      t.integer  :item_id,     null: false
      t.integer  :grant_id,    null: false
      t.integer  :applicant_id, null: false
      t.string   :event,       null: false
      t.integer  :whodunnit # user id
      t.text     :object
      t.datetime :created_at,  null: false
    end

    add_index :grant_submission_submission_versions, [:item_id], name: 'index_gs_submission_v_on_item_id'
    add_index :grant_submission_submission_versions, :grant_id,  name: 'index_gs_submission_v_on_grant_id'
    add_index :grant_submission_submission_versions, %i[grant_id applicant_id], name: 'index_gs_submission_v_on_grant_id_applicant_it'
    add_index :grant_submission_submission_versions, [:whodunnit], name: 'index_gs_submission_v_on_whodunnit'
  end
end
