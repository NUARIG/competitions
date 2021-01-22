class AddShowReviewCommentsToPanels < ActiveRecord::Migration[6.0]
  def change
    add_column :panels, :show_review_comments, :boolean, null: false, default: false
  end
end
