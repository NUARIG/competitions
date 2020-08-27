require 'rails_helper'

RSpec.describe 'grant reviews reminders requests', type: :request do
  let(:grant)         { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:grant_editor)  { grant.grant_permissions.role_editor.first.user }
  let(:grant_viewer)  { grant.grant_permissions.role_viewer.first.user }
  let(:submission)    { grant.submissions.first }
  let(:reviewer)      { grant.reviewers.first }
  let(:user)          { create(:saml_user) }

  let!(:review)       { create(:incomplete_review, assigner: grant_editor,
                                                  submission: submission,
                                                  reviewer: reviewer) }

  describe '#index' do
    context 'authorized user' do
      before(:each) do
        sign_in(grant_editor)
      end

      context 'with an incomplete review' do
        it 'redirects to the grant reviews page' do
          get reminders_grant_reviews_path(grant_id: grant.id)
          expect(response).to have_http_status :redirect
          expect(response).to redirect_to grant_reviews_path(grant)
        end

        it 'successfuly sets reminded_at' do
          expect(review.reminded_at.nil?).to be true
          get reminders_grant_reviews_path(grant_id: grant.id)
          expect(review.reload.reminded_at.nil?).to be false
        end

        it 'sends an email to the reviewer' do
          get reminders_grant_reviews_path(grant_id: grant.id)
          email = (ActionMailer::Base.deliveries).first
          expect(email.to).to eq([reviewer.email])
          expect(email.subject).to eq I18n.t('mailers.reminder.grant_reviews.subject', grant_name: grant.name)
          expect(email.body.decoded.to_s).to include ("Dear #{reviewer.first_name} #{reviewer.last_name}")
        end
      end

      context 'with a completed review' do
        it 'does not send email' do
          review.update(overall_impact_score: rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE))
          get reminders_grant_reviews_path(grant_id: grant.id)
          expect(ActionMailer::Base.deliveries.count.zero?).to be true
          expect(response).to have_http_status :redirect
          expect(response).to redirect_to grant_reviews_path(grant)
        end
      end
    end

    context 'unauthorized users' do
      context 'grant_viewer' do
        it 'does not send emails' do
          user_may_not_remind(unauthorized_user: grant_viewer)
        end
      end

      context 'user' do
        it 'does not send emails' do
          user_may_not_remind(unauthorized_user: user)
        end
      end
    end

    def user_may_not_remind(unauthorized_user:)
      sign_in(unauthorized_user)
      get reminders_grant_reviews_path(grant_id: grant.id)
      expect(ActionMailer::Base.deliveries.count.zero?).to be true
      expect(response).to have_http_status :redirect
      expect(response).to redirect_to root_path
    end
  end
end

