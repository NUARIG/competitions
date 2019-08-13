class GrantCreatorRequestReviewMailer < ApplicationMailer
  before_action :set_attributes

  def approved
    mail(to: @request.requester.email, subject: I18n.t('mailers.grant_creator_request_reviews.approved.subject'))
  end

  def rejected
    mail(to: @request.requester.email, subject: I18n.t('mailers.grant_creator_request_reviews.rejected.subject'))
  end

  def set_attributes
    @request   = params[:request]
    @requester = @request.requester
  end
end
