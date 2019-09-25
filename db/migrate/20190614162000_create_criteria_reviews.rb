class CreateCriteriaReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :criteria_reviews do |t|
      t.references :criterion, foreign_key: true
      t.references :review,    foreign_key: true
      t.integer    :score
      t.text       :comment

      t.timestamps
    end
  end
end
