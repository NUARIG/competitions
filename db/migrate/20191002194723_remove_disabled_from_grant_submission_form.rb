class RemoveDisabledFromGrantSubmissionForm < ActiveRecord::Migration[5.2]
  def change
    remove_column :grant_submission_forms, :disabled, :boolean
  end
end
