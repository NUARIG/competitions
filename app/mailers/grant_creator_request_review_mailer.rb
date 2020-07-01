class GrantCreatorRequestReviewMailer < ApplicationMailer
  def approved(request:)
    set_attributes(request: request)

    mail(to: @requester.email, subject: I18n.t('mailers.grant_creator_request_review.approved.subject'))
  end

  def rejected(request:)
    set_attributes(request: request)

    mail(to: @requester.email, subject: I18n.t('mailers.grant_creator_request_review.rejected.subject'))
  end

  private

  def set_attributes(request:)
    @request   = request
    @requester = @request.requester
    @application_name = COMPETITIONS_CONFIG[:application_name]
  end
end
