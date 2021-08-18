class ApplicantMailer < ApplicationMailer
  def assignment(submission_applicant:)
    set_attributes(submission_applicant: submission_applicant)

    mail(to: @applicant.email, subject: I18n.t('mailers.applicant_mailer.assignment.subject', application_name: @application_name, title: @title))
  end

  def unassignment(submission_applicant:)
    set_attributes(submission_applicant: submission_applicant)

    mail(to: @applicant.email, subject: I18n.t('mailers.applicant_mailer.unassignment.subject', application_name: @application_name, title: @title))
  end

  private

  def set_attributes(submission_applicant:)
    @applicant        = submission_applicant.applicant
    @submission       = submission_applicant.submission
    @grant            = @submission.grant
    @title            = @submission.title
    @application_name = COMPETITIONS_CONFIG[:application_name]
  end
end
