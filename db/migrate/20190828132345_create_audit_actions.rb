class CreateAuditActions < ActiveRecord::Migration[5.2]
  def change
    create_table :audit_actions do |t|
      t.string 'user_id',    null: false
      t.string 'controller', null: false
      t.string 'action',     null: false
      t.string 'browser'
      t.string 'params'
      t.timestamps
    end

    add_index :audit_actions, [:user_id, :controller]
    add_index :audit_actions, [:user_id, :action]
    add_index :audit_actions, [:controller, :action]
  end
end
