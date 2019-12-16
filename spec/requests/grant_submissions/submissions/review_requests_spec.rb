require 'rails_helper'

RSpec.describe 'grant_submission review requests', type: :request do
  before(:example) do
    ActionMailer::Base.deliveries.clear

    @grant      = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
    @editor     = @grant.grant_permissions.find_by(role: 'editor').user
    @reviewer   = @grant.reviewers.first
    @submission = @grant.submissions.first
  end

  context '#create' do
    before(:each) do
      login_as @editor
    end

    it 'mails the reviewer' do
      post(grant_submission_reviews_path(grant_id: @grant.id,
                                         submission_id: @submission.id,
                                         params: {
                                          reviewer_id: @reviewer.id
                                         },
                                         format: :json))
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      email = (ActionMailer::Base.deliveries).first
      expect(email.to).to eq([@reviewer.email])
      expect(email.subject).to eq('CD2H Competitions: Submission Review Assignment')
    end
  end

  context '#destroy' do
    before(:each) do
      @review     = create(:review, submission: @grant.submissions.first,
                                    assigner: @editor,
                                    reviewer: @reviewer)
      login_as @editor
    end

    it 'mails the reviewer' do
      delete(grant_submission_review_path(grant_id: @grant.id,
                                          submission_id: @submission.id,
                                          id: @review.id,
                                          format: :json))
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      email = (ActionMailer::Base.deliveries).first
      expect(email.to).to eq([@reviewer.email])
      expect(email.subject).to eq('CD2H Competitions: Unassigned Submission Review')
    end
  end
end
