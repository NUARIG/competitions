class AddStateToReviews < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE review_states AS ENUM ('assigned', 'draft', 'submitted');
    SQL

    add_column :reviews, :state, :review_states

    Review.completed.update_all(state: 'submitted')
    Review.incomplete.update_all(state: 'assigned')

    change_column :reviews, :state, :review_states, null: false, default: 'assigned'
  end

  def down
    remove_column :reviews, :state

    execute <<-SQL
      DROP TYPE review_states;
    SQL
  end
end
