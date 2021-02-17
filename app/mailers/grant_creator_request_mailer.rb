class GrantCreatorRequestMailer < ApplicationMailer
  def system_admin_notification(request:)
    set_attributes(request: request)

    if @system_admin_emails.present?
      mail( to:  @system_admin_emails,
            subject: "Pending Grant Creator Requests in #{@application_name}"
          )
    end
  end

  private

  def set_attributes(request:)
    @request              = request
    @requester            = @request.requester
    @system_admin_emails  = User.where(system_admin: true).map { |u| u.email }
    @application_name     = COMPETITIONS_CONFIG[:application_name]
  end
end