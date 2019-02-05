class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.references :organization, foreign_key: true
      t.string :organization_role
      t.string :email
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
