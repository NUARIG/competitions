class CreateGrantSubmissionQuestionVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :grant_submission_question_versions do |t|
      t.string   :item_type,   null: false
      t.integer  :item_id,     null: false
      t.integer  :grant_submission_section_id, null: false
      t.string   :event,       null: false
      t.integer  :whodunnit # user id
      t.text     :object
      t.datetime :created_at,  null: false
    end

    add_index :grant_submission_question_versions, [:item_id], name: 'index_gsqv_on_item_id'
    add_index :grant_submission_question_versions, [:grant_submission_section_id], name: 'index_gsqv_on_section_id'
    add_index :grant_submission_question_versions, [:whodunnit], name: 'index_gsqv_on_whodunnit'
  end
end
