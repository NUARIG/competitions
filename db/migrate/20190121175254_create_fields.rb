class CreateFields < ActiveRecord::Migration[5.2]
  def change
    create_table :fields do |t|
      t.string :type
      t.string :label
      t.string :help_text
      t.string :placeholder
      t.boolean :require

      t.timestamps
    end
  end
end
