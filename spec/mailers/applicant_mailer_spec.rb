require 'rails_helper'
include UsersHelper

RSpec.describe ApplicantMailer, type: :mailer do
  context 'applicant mailers' do
    let(:grant)             { create(:open_grant_with_users_and_form_and_submission) }
    let(:submission)        { grant.submissions.first }
    let(:new_applicant)     { create(:saml_user) }
    let(:sa_new_applicant)  { create(:grant_submission_submission_applicant,
                                      submission: submission,
                                      applicant: new_applicant) }

    let(:editor)            { create(:saml_user) }
    let(:mailer)            { described_class.assignment(submission_applicant: sa_new_applicant, current_user: editor) }

    before(:each) do
      sa_new_applicant
    end

    context 'assignment' do
      it 'has application name and submission title in the subject' do
        expect(mailer.subject).to eq("#{COMPETITIONS_CONFIG[:application_name]}: Assigned as applicant on #{submission.title}")
      end

      it 'uses the applicant\'s email address' do
        expect(mailer.to).to eql [new_applicant.email]
      end

      it 'addresses the applicant by their full name' do
        expect(mailer.body.encoded).to include CGI.escapeHTML("Dear #{new_applicant.first_name} #{new_applicant.last_name}")
      end

      it 'includes a link to the submission page' do
        expect(mailer.body.encoded).to have_link submission.title, href: grant_submission_url(grant, submission)
      end

      it 'includes the grant name' do
        expect(mailer.body.encoded).to have_content grant.name
      end

      it "includes the editor/'s name" do
        expect(mailer.body.encoded).to have_content CGI.escapeHTML("#{editor.first_name} #{editor.last_name}")
      end
    end

    context 'unassignment' do
      let(:grant)             { create(:open_grant_with_users_and_form_and_submission) }
      let(:submission)        { grant.submissions.first }
      let(:applicant)         { create(:saml_user) }
      let(:sa_applicant)      { create(:grant_submission_submission_applicant,
                                        submission: submission,
                                        applicant: applicant) }

      let(:editor)            { create(:saml_user) }
      let(:mailer)            { described_class.unassignment(submission_applicant: sa_applicant, current_user: editor) }

      before(:each) do
        sa_applicant
      end

      it 'has application name and submission title in the subject' do
        expect(mailer.subject).to eq ("#{COMPETITIONS_CONFIG[:application_name]}: Unassigned as applicant on #{submission.title}")
      end

      it 'uses the applicant\'s email address' do
        expect(mailer.to).to eql [applicant.email]
      end

      it 'addresses the applicant by their full name' do
        expect(mailer.body.encoded).to include CGI.escapeHTML("Dear #{applicant.first_name} #{applicant.last_name}")
      end

      it 'includes name to the submission page' do
        expect(mailer.body.encoded).to include(submission.title)
      end

      it 'includes a link to the grants page' do
        expect(mailer.body.encoded).to have_link grant.name, href: grant_url(grant)
      end
    end
  end
end
