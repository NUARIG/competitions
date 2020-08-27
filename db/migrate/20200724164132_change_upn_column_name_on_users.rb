class ChangeUpnColumnNameOnUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :upn, :uid
  end
end
