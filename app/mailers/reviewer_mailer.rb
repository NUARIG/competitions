class ReviewerMailer < ApplicationMailer
  before_action :set_attributes

  def assignment
    mail(to: @reviewer.email, subject: I18n.t('mailers.reviewer_mailer.assignment.subject'))
  end

  def unassignment
    mail(to: @reviewer.email, subject: I18n.t('mailers.reviewer_mailer.unassignment.subject'))
  end

  def opt_out
    @recipient_emails = define_opt_out_recipients
    mail(to:@recipient_emails, subject: I18n.t('mailers.reviewer_mailer.opt_out.subject'))
  end

  private

  def set_attributes
    @review     = params[:review]
    @reviewer   = @review.reviewer
    @submission = @review.submission
    @grant      = @review.grant
  end

  def define_opt_out_recipients
    if @review.assigner.editable_grants.include?(@grant)
      @review.assigner.email
    else
      User.where(id: @grant.grant_permissions.where(role: 'admin').pluck(:user_id)).pluck(:email)
    end
  end
end
