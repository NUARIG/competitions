# frozen_string_literal: true

class CreateGrantPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :grant_permissions do |t|
      t.references :grant, foreign_key: true
      t.references :user, foreign_key: true
      t.string     :role
      t.datetime   :deleted_at

      t.timestamps
    end
  end
end
