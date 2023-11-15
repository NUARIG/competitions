class AddStateToReviews < ActiveRecord::Migration[6.1]
  def up
    add_column :reviews, :state, :string

    Review.where(overall_impact_score: nil).update_all(state: 'assigned')
    Review.where.not(overall_impact_score: nil).update_all(state: 'submitted')

    change_column :reviews, :state, :string, null: false, default: 'assigned'
    
    add_index :reviews, :state
  end

  def down
    remove_index :reviews, :state
    remove_column :reviews, :state
  end
end
