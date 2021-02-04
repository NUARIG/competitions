require 'rails_helper'
include UsersHelper

RSpec.describe GrantCreatorRequestMailer, type: :mailer do
  describe 'approved request' do
    let(:system_admin) { create(:system_admin_saml_user) }
    let(:request) { create(:grant_creator_request) }
    let(:mailer)           { described_class.system_admin_notification(request: request)}

    it 'has the appropriate subject' do
      expect(mailer.subject).to eql "Pending Grant Creator Requests in #{COMPETITIONS_CONFIG[:application_name]}"
    end

    it 'uses the system admins\' email addresses' do
      email = system_admin.email
      expect(mailer.to).to include email
    end

    it 'includes a grant requester\'s name' do
      expect(mailer.body).to have_link full_name(request.requester), href: grant_creator_request_url(request)
    end

    it 'includes a link to the application root url' do
      expect(mailer.body).to include COMPETITIONS_CONFIG[:application_name]
    end

    it 'includes a link to the grants page' do
      expect(mailer.body).to have_link grant_creator_requests_url.to_s, href: grant_creator_requests_url
    end
  end
end
