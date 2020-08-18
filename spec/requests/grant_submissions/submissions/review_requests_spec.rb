require 'rails_helper'

RSpec.describe 'grant_submission review requests', type: :request do
  def random_score
    rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE)
  end

  def criteria_params
    criteria_review_params = {}
    grant.criteria.each_with_index do |criteria, index|
      criteria_review_params[index] = { criterion_id: criteria.id,
                                        score: random_score }
    end
    criteria_review_params
  end

  let(:grant)        { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:grant_editor) { grant.grant_permissions.role_editor.first.user }
  let(:grant_viewer) { grant.grant_permissions.role_viewer.first.user }
  let(:submission)   { grant.submissions.first }
  let(:reviewer)     { grant.reviewers.first }
  let(:review)       { create(:review, submission: submission,
                                       assigner: grant.grant_permissions.role_admin.first.user,
                                       reviewer: reviewer) }
  let(:invalid_user) { create(:user) }

  context 'mailers' do
    before(:example) do
      ActionMailer::Base.deliveries.clear
    end

    context '#create' do
      before(:each) do
        login_as grant_editor
      end

      it 'mails the reviewer' do
        post(grant_submission_reviews_path(grant_id: grant.id,
                                           submission_id: submission.id,
                                           params: {
                                            reviewer_id: reviewer.id
                                           },
                                           format: :json))
        expect(ActionMailer::Base.deliveries.size).to eq(1)
        email = (ActionMailer::Base.deliveries).first
        expect(email.to).to eq([reviewer.email])
        expect(email.subject).to eq("#{COMPETITIONS_CONFIG[:application_name]}: Submission Review Assignment")
      end
    end

    context '#destroy' do
      before(:each) do
        login_as grant_editor
      end

      it 'mails the reviewer' do
        delete(grant_submission_review_path(grant_id: grant.id,
                                            submission_id: submission.id,
                                            id: review.id,
                                            format: :json))
        expect(ActionMailer::Base.deliveries.size).to eq(1)
        email = (ActionMailer::Base.deliveries).first
        expect(email.to).to eq([reviewer.email])
        expect(email.subject).to eq("#{COMPETITIONS_CONFIG[:application_name]}: Unassigned Submission Review")
      end
    end
  end

  context '#index' do
    before(:each) do
      review.touch
      sign_in(grant_editor)
    end

    context 'pdf formats' do
      it 'renders a pdf' do
        get grant_submission_reviews_path(grant, submission), headers: { "ACCEPT" => "application/pdf" }

        expect(response.content_type).to eql 'application/pdf'
      end
    end
  end

  context '#show' do
    context 'kept' do
      it 'sucessfully renders to reviewer' do
        sign_in(review.reviewer)
        get grant_submission_review_path(grant, submission, review)

        expect(response).to have_http_status(:success)
      end

      it 'redirects the applicant' do
        sign_in(review.submission.applicant)
        get grant_submission_review_path(grant, submission, review)

        expect(response).to have_http_status(:redirect)
      end

      it 'redirects an invalid user' do
        sign_in(invalid_user)
        get grant_submission_review_path(grant, submission, review)

        expect(response).to have_http_status(:redirect)
      end
    end

    context 'discarded', with_errors_rendered: true do
      it 'renders 404' do
        sign_in(review.reviewer)
        grant.discard
        get grant_submission_review_path(grant, submission, review)

        expect(response).to have_http_status(404)
      end
    end
  end

  context '#edit' do
    it 'udpates the submission average_overall_impact_score' do
      sign_in(review.reviewer)

      expect do
        patch(grant_submission_review_path(grant_id: grant.id,
                                           submission_id: submission.id,
                                           id: review.id,
                                           params: {
                                             review: {
                                               overall_impact_score: rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE),
                                               criteria_reviews_attributes: criteria_params
                                             }
                                           }))
      end.to change{ submission.reload.average_overall_impact_score }
    end

    it 'udpates the submission composite score' do
      sign_in(review.reviewer)

      expect do
        patch(grant_submission_review_path(grant_id: grant.id,
                                           submission_id: submission.id,
                                           id: review.id,
                                           params: {
                                             review: {
                                               overall_impact_score: rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE),
                                               criteria_reviews_attributes: criteria_params
                                             }
                                           }))
      end.to change{ submission.reload.composite_score }
    end

    it 'redirects the applicant' do
      sign_in(review.submission.applicant)
      get edit_grant_submission_review_path(grant, submission, review)

      expect(response).to have_http_status(:redirect)
    end

    it 'redirects a grant viewer' do
      sign_in(grant_viewer)
      get edit_grant_submission_review_path(grant, submission, review)

      expect(response).to have_http_status(:redirect)
    end
  end
end
