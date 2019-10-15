class RemoveRepeatableFromGrantSubmissionSections < ActiveRecord::Migration[5.2]
  def change
    remove_column :grant_submission_sections, :repeatable, :boolean
  end
end
