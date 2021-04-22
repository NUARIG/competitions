module GrantPermissionMailers
  class SubmissionMailer < ApplicationMailer
    def submitted_notification(grant:, recipients:, submission:)
      set_attributes(submission: submission,
                     grant: grant,
                     recipients: recipients)

      mail( bcc:     @recipients,
            subject: "New submission available for #{@grant.name} in #{@application_name}" )
    end

    private

    def set_attributes(submission:, grant:, recipients:)
      @submission         = submission
      @applicant          = submission.applicant
      @grant              = grant
      @recipients         = recipients
      @application_name   = COMPETITIONS_CONFIG[:application_name]
    end
  end
end
