require 'rails_helper'
include UsersHelper

RSpec.describe ReminderMailer, type: :mailer do
  describe 'grant reviews reminder' do
    let(:grant) { create(:open_grant_with_users_and_form_and_submission_and_reviewer, max_submissions_per_reviewer: 5) }
    let(:grant_editor)  { grant.grant_permissions.role_editor.first.user }
    let(:submission)    { grant.submissions.first }
    let(:reviewer)      { grant.reviewers.first }
    let(:user)          { create(:saml_user) }

    let!(:review)       { create(:incomplete_review, assigner: grant_editor,
                                                    submission: submission,
                                                    reviewer: reviewer) }


    context 'one review' do
      let(:mailer)  { described_class.grant_reviews_reminder( grant: grant,
                                                              reviewer: reviewer,
                                                              incomplete_reviews: Review.by_grant(grant).by_reviewer(reviewer).incomplete)}

      it 'has the correct subject' do
        expect(mailer.subject).to eql I18n.t('mailers.reminder.grant_reviews.subject', grant_name: grant.name)
      end

      it 'addresses the reviewer by their full name' do
        expect(mailer.body.encoded).to include "Dear #{reviewer.first_name} #{CGI.escapeHTML(reviewer.last_name)}"
      end

      it 'includes a link to the grant' do
        expect(mailer.body.encoded).to have_link grant.name, href: grant_url(grant)
      end

      it 'includes a link to the grant' do
        expect(mailer.body.encoded).to have_link submission.title, href: grant_submission_url(grant, submission)
      end

      it 'includes a link to the grant' do
        expect(mailer.body.encoded).to have_link "all your reviews for #{grant.name}"
      end
    end

    context 'multiple reviews' do
      let(:other_submission)  {create(:submission_with_responses, grant: grant,
                                                                  form: grant.form,
                                                                  applicant: user) }
      let!(:other_review)     { create(:incomplete_review,  submission: other_submission,
                                                            assigner: grant_editor,
                                                            reviewer: reviewer) }
      let(:mailer)            { described_class.grant_reviews_reminder( grant: grant,
                                                                        reviewer: reviewer,
                                                                        incomplete_reviews: Review.by_grant(grant).by_reviewer(reviewer).incomplete) }

      it 'includes links to all submissions with incomplete reviews' do
        expect(mailer.body.encoded).to have_link submission.title, href: grant_submission_url(grant, submission)
        expect(mailer.body.encoded).to have_link other_submission.title, href: grant_submission_url(grant, other_submission)
      end

      it 'does not include link to completed review' do
        other_review.update(overall_impact_score: rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE))

        expect(mailer.body.encoded).to have_link submission.title, href: grant_submission_url(grant, submission)
        expect(mailer.body.encoded).not_to have_link other_submission.title, href: grant_submission_url(grant, other_submission)
      end
    end
  end
end
