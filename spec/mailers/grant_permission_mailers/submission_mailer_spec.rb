require 'rails_helper'
include UsersHelper

RSpec.describe GrantPermissionMailers::SubmissionMailer, type: :mailer do
  describe 'approved request' do

    let!(:grant)       { create(:published_open_grant_with_users) }
    let!(:submission)  { create(:grant_submission_submission, grant: grant) }
    let(:mailer)       { described_class.submitted_notification(grant: grant,
                                                                recipients: get_recipients,
                                                                submission: submission)}


    def get_recipients
      grant.grant_permissions
           .with_user
           .where(submission_notification: true)
           .map{ |permission| permission.user.email }
    end

    context 'grant permissions accepting submission notifications' do
      before(:each) do
        grant.grant_permissions.role_admin.update(submission_notification: true)
        grant.grant_permissions.role_viewer.update(submission_notification: true)
      end

      it 'has the appropriate subject' do
        expect(mailer.subject).to eql("New submission available for #{grant.name} in #{COMPETITIONS_CONFIG[:application_name]}")
      end

      it 'uses the correct system admin email addresses' do
        emails  = []
        emails  << grant.grant_permissions.role_admin.first.user.email
        emails  << grant.grant_permissions.role_viewer.first.user.email
        expect(mailer.bcc).to match_array emails
      end

      it 'includes the application root name and link' do
        expect(mailer.body).to have_link(COMPETITIONS_CONFIG[:application_name], href: root_url)
      end

      it 'includes grant name and link' do
        expect(mailer.body).to have_link(grant.name, href: grant_url(grant))
      end

      it "includes the submitter\'s name" do
        expect(mailer.body).to include(full_name(submission.submitter))
      end

      it 'includes a submission title' do
        expect(mailer.body).to have_link(submission.title, href: grant_submission_url(grant, submission))
      end
    end
  end
end
