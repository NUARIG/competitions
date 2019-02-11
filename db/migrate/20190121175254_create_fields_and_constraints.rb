class CreateFieldsAndConstraints < ActiveRecord::Migration[5.2]
  def change
    create_table :fields do |t|
      t.string :type
      t.string :label
      t.string :help_text
      t.string :placeholder
      t.boolean :require

      t.timestamps
    end

    create_table :constraints do |t|
      t.string :type
      t.string :name
      t.string :value_type
      t.string :default

      t.timestamps
    end

    add_index :constraints, [:value_type]
  end
end
