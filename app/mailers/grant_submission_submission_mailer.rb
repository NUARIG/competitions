class GrantSubmissionSubmissionMailer < ApplicationMailer
  def grant_admin_submission_notification(submission:)
    set_attributes(submission: submission)

    mail( bcc:  @grant_admin_emails,
          subject: "New submission available for #{@grant.name} in #{@application_name}"
        )
  end

  private

  def set_attributes(submission:)
    @submission           = submission
    @applicant            = @submission.applicant
    @grant                = @submission.grant
    @grant_admin_emails   = GrantPermission.submission_notification_emails(grant: @grant)
    @application_name     = COMPETITIONS_CONFIG[:application_name]
  end
end