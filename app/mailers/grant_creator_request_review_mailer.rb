class GrantCreatorRequestReviewMailer < ApplicationMailer
  def approved(request:)
    @request   = request
    @requester = @request.requester

    mail(to: @requester.email, subject: I18n.t('mailers.grant_creator_request_review.approved.subject'))
  end

  def rejected(request:)
    @request   = request
    @requester = @request.requester

    mail(to: @requester.email, subject: I18n.t('mailers.grant_creator_request_review.rejected.subject'))
  end
end
