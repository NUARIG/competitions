class AddUpnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :upn, :string, null: false, default: ''
  end
end
