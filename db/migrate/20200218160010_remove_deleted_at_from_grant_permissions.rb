class RemoveDeletedAtFromGrantPermissions < ActiveRecord::Migration[5.2]
  def change
    remove_column :grant_permissions, :deleted_at, :datetime
  end
end
