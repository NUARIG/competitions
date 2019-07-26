class AddNameIdentifierToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :name_identifier, :string, null: false, default: ''
  end
end
