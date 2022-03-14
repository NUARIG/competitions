class RemoveDeviseRememberable < ActiveRecord::Migration[6.1]
  def up
    remove_column :users, :remember_created_at
  end

  def down
    add_column :users, :remember_created_at, :datetime
  end
end
