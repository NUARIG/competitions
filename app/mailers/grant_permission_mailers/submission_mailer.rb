module GrantPermissionMailers
  class SubmissionMailer < ApplicationMailer
    def submitted_notification(submission:)
      set_attributes(submission: submission)

      if @recipients.present?
        mail( bcc:  @recipients,
              subject: "New submission available for #{@grant.name} in #{@application_name}"
            )
      end
    end

    private

    def set_attributes(submission:)
      @submission         = submission
      @submitter          = @submission.submitter
      @grant              = @submission.grant
      @recipients         = GrantPermission.submission_notification_emails(grant: @grant)
      @application_name   = COMPETITIONS_CONFIG[:application_name]
    end
  end
end