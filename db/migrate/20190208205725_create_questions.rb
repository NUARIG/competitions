class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.references :field
      t.references :grant
      t.text :name
      t.text :help_text
      t.text :placeholder_text
      t.boolean :required

      t.timestamps
    end

    add_index :questions, [:field_id, :grant_id]
  end
end
