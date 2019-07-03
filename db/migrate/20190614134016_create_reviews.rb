class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.references :grant_submission_submission, foreign_key: true, null: false
      t.bigint     :assigner_id,                 foreign_key: true, null: false
      t.bigint     :reviewer_id, foreign_key: true, null: false
      t.integer    :overall_impact_score # default null
      t.text       :overall_impact_comment # default null

      t.timestamps
    end

    add_index :reviews, [:grant_submission_submission_id, :assigner_id], unique: true, name: 'index_review_reviewer_on_grant_submission_id_and_assigner_id'
  end
end
