# frozen_string_literal: true

class CreateGrantVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :grant_versions do |t|
      t.string   :item_type, null: false
      t.integer  :item_id,   null: false
      t.string   :event,     null: false
      t.integer  :whodunnit # user id
      t.text     :object
      t.datetime :created_at, null: false
    end
    add_index :grant_versions, %i[item_type item_id]
    add_index :grant_versions, [:whodunnit]
  end
end
