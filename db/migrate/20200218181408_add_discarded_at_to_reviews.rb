class AddDiscardedAtToReviews < ActiveRecord::Migration[5.2]
  def up
    add_column :reviews, :discarded_at, :datetime
    add_index :reviews, :discarded_at, name: "index_reviews_on_discarded_at"
  end

  def down
    remove_index :reviews, :discarded_at
    remove_column :reviews, :discarded_at, :datetime
  end
end
