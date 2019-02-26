class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.references :grant
      t.text :answer_type
      t.text :name
      t.text :help_text
      t.text :placeholder_text
      t.boolean :required

      t.timestamps
    end
  end
end
