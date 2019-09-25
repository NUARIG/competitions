class CreateCriteriaReviewVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :criteria_review_versions do |t|
      t.string   :item_type, null: false
      t.integer  :item_id,   null: false
      t.integer  :review_id, null: false
      t.string   :event,     null: false
      t.integer  :whodunnit # user id
      t.text     :object
      t.datetime :created_at, null: false
    end

    add_index :criteria_review_versions, [:item_id]
    add_index :criteria_review_versions, [:review_id]
    add_index :criteria_review_versions, [:whodunnit]
  end
end
