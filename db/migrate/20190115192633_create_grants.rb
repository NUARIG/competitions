class CreateGrants < ActiveRecord::Migration[5.2]
  def change
    create_table :grants do |t|
      t.references :organization, foreign_key: true
      t.string :name
      t.string :short_name

      t.timestamps
    end
  end
end
