class CreateConstraintQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :constraint_questions do |t|
      t.references :constraint
      t.references :question
      t.string     :value

      t.timestamps
    end

    add_index :constraint_questions, [:constraint_id, :question_id]
  end
end
