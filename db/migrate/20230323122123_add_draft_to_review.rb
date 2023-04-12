class AddDraftToReview < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :draft, :boolean, null: false, default: true
  end
end
