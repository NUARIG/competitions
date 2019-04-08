# frozen_string_literal: true

class CreateSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :submissions do |t|
      t.references :grant, foreign_key: true
      t.references :user, foreign_key: true
      t.string :project_title
      t.string :state
      t.float :composite_score_average
      t.float :final_impact_score_average
      t.float :award_amount

      t.timestamps
    end
  end
end
