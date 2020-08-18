class ChangeUserOrganizationRoleToSystemAdmin < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :system_admin, :boolean, null: false, default: false
    User.where(organization_role: 'admin').update_all(system_admin: true)
    remove_column :users, :organization_role
  end

  def down
    add_column :users, :organization_role, null: false, default: 'none'
    User.where(system_admin: true).update_all(organization_role: 'admin')
    remove_column :users, :system_admin
  end
end

