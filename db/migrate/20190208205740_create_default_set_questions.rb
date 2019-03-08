class CreateDefaultSetQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :default_set_questions do |t|
      t.references :default_set
      t.references :question

      t.timestamps
    end
    add_index :default_set_questions, [:default_set_id, :question_id]
  end
end
