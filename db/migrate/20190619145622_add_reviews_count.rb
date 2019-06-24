class AddReviewsCount < ActiveRecord::Migration[5.2]
  def change
    add_column :grant_submission_submissions, :reviews_count, :integer, default: 0
  end
end
