require 'rails_helper'

RSpec.describe 'grant_submission review opt_out requests', type: :request do
  context '#delete' do
    before(:each) do
      ActionMailer::Base.deliveries.clear

      @grant    = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
      @admin    = @grant.grant_permissions.where(role: 'admin').first.user
      @assigner = @grant.grant_permissions.where(role: 'editor').first.user
      @reviewer = @grant.reviewers.first
      @review   = create(:review, submission: @grant.submissions.first,
                                  assigner: @assigner,
                                  reviewer: @reviewer)

      login_user @reviewer
    end

    it 'mails the assigner' do
      delete(opt_out_grant_submission_review_path(id: @review.id,
                                                  grant_id: @grant.id,
                                                  submission_id: @grant.submissions.first.id))
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      email = (ActionMailer::Base.deliveries).first
      expect(email.to).to eq([@assigner.email])
      expect(email.subject).to eq("#{COMPETITIONS_CONFIG[:application_name]}: Reviewer Opt Out Notification")
    end

    it 'mails grant admin when the assigner no longer has grant permissions' do
      @grant.grant_permissions.find_by(user: @assigner).delete

      delete(opt_out_grant_submission_review_path(id: @review.id,
                                                  grant_id: @grant.id,
                                                  submission_id: @grant.submissions.first.id))
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      email = (ActionMailer::Base.deliveries).first
      expect(email.to).to eq([@admin.email])
      expect(email.subject).to eq("#{COMPETITIONS_CONFIG[:application_name]}: Reviewer Opt Out Notification")
    end
  end
end
