class RemoveColumnSessionIndexOnUsers < ActiveRecord::Migration[5.2]
  def up
    remove_column :users, :session_index
  end

  def down
    add_column :users, :session_index, :string
    User.update_all(session_index: "valid")
    change_column_null :users, :session_index, true
  end
end
