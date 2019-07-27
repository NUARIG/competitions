class ChangeUserOrganizationRoleToSystemAdmin < ActiveRecord::Migration[5.2]
  def up
    rename_column :users, :organization_role, :system_admin
    change_column :users, :system_admin, 'boolean USING (CASE system_admin WHEN \'admin\' THEN \'t\'::boolean ELSE \'f\'::boolean END)', null: false, default: false
  end

  def down
    rename_column :users, :system_admin, :organization_role
    change_column :users, :organization_role, 'varchar(255) USING (CASE when organization_role THEN \'admin\' else \'none\' end)', null: false, default: 'none'
  end
end


