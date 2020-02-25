class RenameDeletedAtInGrants < ActiveRecord::Migration[5.2]
  def up
    rename_column :grants, :deleted_at, :discarded_at
    add_index :grants, :discarded_at
  end

  def down
    remove_index :grants, :discarded_at
    rename_column :grants, :discarded_at, :deleted_at
  end
end
