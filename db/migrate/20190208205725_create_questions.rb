# frozen_string_literal: true

class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.references :grant
      t.text :answer_type
      t.text :text
      t.text :help_text
      t.boolean :required

      t.timestamps
    end
  end
end
