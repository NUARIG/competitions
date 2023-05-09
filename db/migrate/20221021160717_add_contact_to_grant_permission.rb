class AddContactToGrantPermission < ActiveRecord::Migration[6.1]
  def change
    add_column :grant_permissions, :contact, :boolean, null: false, default: false
  end
end
