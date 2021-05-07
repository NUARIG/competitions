class CopySubmitterToSubmissionApplicant < ActiveRecord::Migration[6.0]
  def up
    GrantSubmission::Submission.all.each do |submission|
      GrantSubmission::SubmissionApplicant.create!(grant_submission_submission_id: submission.id,
                                         applicant_id: submission.submitter.id)
    end
  end

  def down
    # There is no way to undo this and will be "fixed" once the table is removed in
    # a rollback of migration 20210322143522_create_grant_submission_applicants.rb.
  end
end
