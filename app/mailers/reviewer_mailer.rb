class ReviewerMailer < ApplicationMailer
  def assignment(review:)
    set_attributes(review: review)

    mail(to: @reviewer.email, subject: I18n.t('mailers.reviewer_mailer.assignment.subject', application_name: @application_name))
  end

  def unassignment(review:)
    set_attributes(review: review)

    mail(to: @reviewer.email, subject: I18n.t('mailers.reviewer_mailer.unassignment.subject', application_name: @application_name))
  end

  def opt_out(review:)
    set_attributes(review: review)

    mail(to: get_opt_out_recipients, subject: I18n.t('mailers.reviewer_mailer.opt_out.subject', application_name: @application_name))
  end

  private

  def set_attributes(review:)
    @review           = review
    @reviewer         = @review.reviewer
    @submission       = @review.submission
    @grant            = @review.grant
    @application_name = COMPETITIONS_CONFIG[:application_name]
  end

  def get_opt_out_recipients
    if @review.assigner.editable_grants.include?(@grant)
      @review.assigner.email
    else
      User.where(id: @grant.grant_permissions.where(role: 'admin').pluck(:user_id)).pluck(:email)
    end
  end
end
