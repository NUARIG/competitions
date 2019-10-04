class RenameDescriptionToSubmissionInstructions < ActiveRecord::Migration[5.2]
  def up
    rename_column :grant_submission_forms, :description, :submission_instructions
  end

  def down
    rename_column :grant_submission_forms, :submission_instructions, :description
  end
end
