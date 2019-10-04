class RemoveTitleFromGrantSubmissionForms < ActiveRecord::Migration[5.2]
  def up
    remove_index  :grant_submission_forms, column: :title
    remove_column :grant_submission_forms, :title
  end

  def down
    add_column :grant_submission_forms, :title, :string, null: false
    add_index :grant_submission_forms, :title, unique: true
  end
end
