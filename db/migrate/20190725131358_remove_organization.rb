class RemoveOrganization < ActiveRecord::Migration[5.2]
  def change
    drop_table "organizations", force: :cascade do |t|
      t.string "name"
      t.string "slug"
      t.string "url"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    remove_column :grants, :organization_id

    remove_column :users, :organization_id
  end
end
