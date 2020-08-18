require 'rails_helper'
include UsersHelper

RSpec.describe GrantCreatorRequestReviewMailer, type: :mailer do
  describe 'approved request' do
    let(:approved_request) { create(:reviewed_approved_grant_creator_request) }
    let(:mailer)           { described_class.approved(request: approved_request)}

    it 'has the appropriate subject' do

      expect(mailer.subject).to eql "#{COMPETITIONS_CONFIG[:application_name]}: Approved Grant Creator Request"
    end

    it 'uses the requester\'s email address' do
      expect(mailer.to).to include approved_request.requester.email
    end

    it 'includes a link to the grants page' do
      expect(mailer.body).to have_link 'http://localhost:3000/profile/grants', href: profile_grants_url
    end

    it 'includes a link to the application root url' do
      expect(mailer.body).to have_link COMPETITIONS_CONFIG[:application_name], href: root_url
    end

    it 'addresses the requester by their full name' do
      requester = approved_request.requester
      expect(mailer.body.encoded).to include "Dear #{requester.first_name} #{CGI.escapeHTML(requester.last_name)}"
    end
  end

  describe 'rejected request' do
    let(:rejected_request) { create(:reviewed_rejected_grant_creator_request) }
    let(:mailer) { described_class.rejected(request: rejected_request) }

    it 'uses the requester\'s email address' do
      expect(mailer.to).to include rejected_request.requester.email
    end

    it 'has the appropriate subject' do
      expect(mailer.subject).to eql "#{COMPETITIONS_CONFIG[:application_name]}: Rejected Grant Creator Request"
    end

    it 'includes a link to grants creator request page' do
      expect(mailer.body).to have_link href: new_grant_creator_request_url
    end

    it 'includes a link to the application root url' do
      expect(mailer.body).to have_link COMPETITIONS_CONFIG[:application_name], href: root_url
    end

    it 'addressed the requester by their full name' do
      requester = rejected_request.requester
      expect(mailer.body.encoded).to include "Dear #{requester.first_name} #{CGI.escapeHTML(requester.last_name)}"
    end
  end

end
