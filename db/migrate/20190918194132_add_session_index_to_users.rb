class AddSessionIndexToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :session_index, :string
    User.update_all(session_index: "valid")
    change_column_null :users, :session_index, false
  end

  def down
    remove_column :users, :session_index
  end
end
