require 'rails_helper'

RSpec.describe 'grant_submission unsubmit requests', type: :request do
  let(:grant)           { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:grant_editor)    { grant.grant_permissions.role_editor.first.user }
  let(:grant_viewer)    { grant.grant_permissions.role_viewer.first.user }
  let(:submission)      { grant.submissions.first }
  let(:reviewer)        { grant.reviewers.first }
  let(:scored_review)   { create(:scored_review_with_scored_mandatory_criteria_review, submission: submission,
                                                                                       assigner: grant_editor,
                                                                                       reviewer: reviewer) }
  let(:unscored_review) { create(:incomplete_review, submission: submission,
                                                     assigner: grant_editor,
                                                     reviewer: reviewer) }

  def successful_unsubmit_message
    'You have changed the status of this submission to Draft. It may now be edited by the applicant.'
  end

  def draft_unsubmit_message
    'This submission is already editable.'
  end

  def reviewed_submission_unsubmit_error
    I18n.t('activerecord.errors.models.grant_submission/submission.attributes.base.reviewed_submission_cannot_be_unsubmitted')
  end

  def draft_status
    GrantSubmission::Submission::SUBMISSION_STATES[:draft]
  end

  def submitted_status
    GrantSubmission::Submission::SUBMISSION_STATES[:submitted]
  end

  context '#update' do
    before(:each) do
      sign_in(grant_editor)
    end

    context 'kept' do
      context 'submitted' do
        context 'no reviews' do
          it 'sucessfully changes the state of the submission' do
            patch unsubmit_grant_submission_path(grant_id: grant.id, id: submission.id)
            follow_redirect!
            expect(response.body).to include(successful_unsubmit_message)
            expect(submission.reload.state).to eql draft_status
          end
        end

        context 'with reviews' do
          context 'scored' do
            it 'cannot be unsubmitted' do
              scored_review.reload
              patch unsubmit_grant_submission_path(grant_id: grant.id, id: submission.id)
              follow_redirect!
              expect(response.body).to include(reviewed_submission_unsubmit_error)
              expect(submission.reload.state).to eql submitted_status
            end
          end

          context 'unscored' do
            it 'can be unsubmitted' do
              unscored_review.reload
              patch unsubmit_grant_submission_path(grant_id: grant.id, id: submission.id)
              follow_redirect!
              expect(response.body).to include(successful_unsubmit_message)
              expect(submission.reload.state).to eql draft_status
            end
          end
        end
      end

      context 'draft' do
        it 'does not change status' do
          submission.update_attribute(:state, GrantSubmission::Submission::SUBMISSION_STATES[:draft])
          patch unsubmit_grant_submission_path(grant_id: grant.id, id: submission.id)
          follow_redirect!
          expect(response.body).to include(draft_unsubmit_message)
          expect(submission.reload.state).to eql draft_status
        end
      end
    end
  end
end
