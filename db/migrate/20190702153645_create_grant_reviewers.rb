class CreateGrantReviewers < ActiveRecord::Migration[5.2]
  def change
    create_table :grant_reviewers do |t|
      t.belongs_to :grant,        null: false
      t.bigint     :reviewer_id,  null: false
    end

    add_index :grant_reviewers, [:reviewer_id]
  end
end
