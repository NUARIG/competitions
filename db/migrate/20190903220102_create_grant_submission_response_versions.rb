class CreateGrantSubmissionResponseVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :grant_submission_response_versions do |t|
      t.string   :item_type,   null: false
      t.integer  :item_id,     null: false
      t.integer  :grant_submission_question_id, null: false
      t.string   :event,       null: false
      t.integer  :whodunnit # user id
      t.text     :object
      t.datetime :created_at,  null: false
    end

    add_index :grant_submission_response_versions, [:item_id], name: 'index_gsrv_on_item_id'
    add_index :grant_submission_response_versions, [:grant_submission_question_id], name: 'index_gsrv_on_question_id'
    add_index :grant_submission_response_versions, [:whodunnit], name: 'index_gsrv_on_whodunnit'
  end
end
