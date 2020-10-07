class CreatePanelVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :panel_versions do |t|
      t.string    :item_type,   null: false
      t.integer   :item_id,     null: false
      t.integer   :grant_id,    null: false
      t.string    :event,       null: false
      t.integer   :whodunnit  # user id
      t.text      :object
      t.datetime  :created_at,  null: false
    end

    add_index :panel_versions, [:grant_id]
    add_index :panel_versions, [:item_id]
    add_index :panel_versions, [:whodunnit]
  end
end
