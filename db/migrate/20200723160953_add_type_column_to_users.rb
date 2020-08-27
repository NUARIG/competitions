class AddTypeColumnToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :type, :string
    User.update_all(type: "SamlUser")
    change_column_null :users, :type, true
  end

  def down
    remove_column :users, :type
  end
end
