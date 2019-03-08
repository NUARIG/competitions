class CreateDefaultSets < ActiveRecord::Migration[5.2]
  def change
    create_table :default_sets do |t|
      t.string :name

      t.timestamps
    end
  end
end
