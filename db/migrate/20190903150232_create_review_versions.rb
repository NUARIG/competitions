class CreateReviewVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :review_versions do |t|
      t.string   :item_type,   null: false
      t.integer  :item_id,     null: false
      t.integer  :grant_id,    null: false
      t.integer  :reviewer_id, null: false
      t.string   :event,       null: false
      t.integer  :whodunnit # user id
      t.text     :object
      t.datetime :created_at,  null: false
    end

    add_index :review_versions, [:grant_id]
    add_index :review_versions, [:item_id]
    add_index :review_versions, [:whodunnit]
  end
end
