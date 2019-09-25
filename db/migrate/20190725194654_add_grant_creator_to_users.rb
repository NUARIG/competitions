class AddGrantCreatorToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :grant_creator, :boolean, null: false, default: false
  end
end
