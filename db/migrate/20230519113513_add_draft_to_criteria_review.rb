class AddDraftToCriteriaReview < ActiveRecord::Migration[6.1]
  def change
    add_column :criteria_reviews, :draft, :boolean, null: false, default: true
  end
end
