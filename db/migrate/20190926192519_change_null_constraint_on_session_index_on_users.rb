class ChangeNullConstraintOnSessionIndexOnUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :session_index, true
  end
end
