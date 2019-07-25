class AddGrantCreatorToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :grant_creator, :boolean, default: false
  end
end
