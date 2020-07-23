class AddRemindedAtToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :reminded_at, :datetime
  end
end
