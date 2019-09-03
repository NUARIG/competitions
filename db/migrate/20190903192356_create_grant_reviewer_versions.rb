class CreateGrantReviewerVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :grant_reviewer_versions do |t|
      t.string   :item_type,   null: false
      t.integer  :item_id,     null: false
      t.integer  :grant_id,    null: false
      t.integer  :reviewer_id, null: false
      t.string   :event,       null: false
      t.integer  :whodunnit # user id
      t.text     :object
      t.datetime :created_at,  null: false
    end

    add_index :grant_reviewer_versions, [:item_id]
    add_index :grant_reviewer_versions, [:grant_id]
    add_index :grant_reviewer_versions, [:reviewer_id]
    add_index :grant_reviewer_versions, [:whodunnit]
  end
end
