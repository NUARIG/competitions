class AddValidationsAndIndexesOnApplicants < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :grant_submission_applicants, :grant_submission_submission, validate: true
    change_column_null :grant_submission_applicants, :grant_submission_submission, false

    add_foreign_key :grant_submission_applicants, :user, validate: true
    change_column_null :grant_submission_applicants, :user, false
  end
end
