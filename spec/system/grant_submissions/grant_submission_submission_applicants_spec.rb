require 'rails_helper'
include UsersHelper

RSpec.describe 'GrantSubmission::Submission SubmissionApplicants', type: :system do



  let(:open_grant)            { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:submission)            { open_grant.submissions.first }
  let(:submitter)             { submission.submitter }
  let(:sa_submitter)          { create(:grant_submission_submission_applicant,
                                        submission: submission,
                                        applicant: submitter) }
  let(:applicant)             { create(:saml_user) }
  let(:sa_applicant)          { create(:grant_submission_submission_applicant,
                                        submission: submission,
                                        applicant: applicant) }
  let(:system_admin)          { create(:system_admin_saml_user) }
  let(:grant_admin)           { grant.administrators.first }
  let(:grant_editor)          { grant.administrators.second }
  let(:grant_viewer)          { grant.administrators.third }
  let(:new_submitter)         { create(:saml_user) }
  let(:draft_submission)      { create(:draft_submission_with_responses,
                                        grant: open_grant,
                                        form: open_grant.form) }
  let(:draft_sa_submitter)    { create(:grant_submission_submission_applicant,
                                        submission: draft_submission,
                                        applicant:  draft_submission.submitter) }
  let(:draft_applicant)       { create(:saml_user) }
  let(:draft_sa_applicant)    { create(:grant_submission_submission_applicant,
                                        submission: draft_submission,
                                        applicant: draft_applicant) }
  let(:draft_grant)           { create(:draft_grant) }
  let(:other_submission)      { create(:grant_submission_submission, grant: open_grant) }
  let(:review)                { create(:scored_review_with_scored_mandatory_criteria_review,
                                        submission: submission,
                                        assigner: grant_admin,
                                        reviewer: open_grant.reviewers.first) }
  let(:new_reviewer)          { create(:grant_reviewer, grant: open_grant) }
  let(:new_review)            { create(:scored_review_with_scored_mandatory_criteria_review,
                                        submission: submission,
                                        assigner: grant_admin,
                                        reviewer: new_reviewer.reviewer) }
  let(:unscored_review)       { create(:incomplete_review,
                                        submission: submission,
                                        assigner: grant_admin,
                                        reviewer: create(:grant_reviewer, grant: open_grant).reviewer ) }
  let(:unreviewed_submission) { create(:submission_with_responses,
                                        grant: open_grant,
                                        form: open_grant.form) }
  let(:admin_submission)      { create(:submission_with_responses,
                                        grant: open_grant,
                                        form: open_grant.form,
                                        submitter: grant_admin,
                                        created_at: grant.submission_close_date - 1.hour) }
  let(:editor_submission)     { create(:submission_with_responses,
                                        grant: open_grant,
                                        form: open_grant.form,
                                        submitter: grant_editor,
                                        created_at: grant.submission_close_date - 1.hour) }
  let(:viewer_submission)     { create(:submission_with_responses,
                                        grant: open_grant,
                                        form: open_grant.form,
                                        submitter: grant_viewer,
                                        created_at: grant.submission_close_date - 1.hour) }



  describe '#index', js: true do
    before(:each) do
      @open_grant         = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
      @admin              = @open_grant.grant_permissions.role_admin.first.user
      @draft_submission   = draft_submission

    end

    context 'submission in draft mode' do
      context 'Admin' do
        before(:each) do
          login_as(@admin, scope: :saml_user)
          visit grant_submissions_path(@open_grant)
        end

        scenario 'displays applicants' do
          # byebug
          # expect(page).to have_text 'There are no reviews for this submission.'
          # expect(page).to have_link 'Assign it to a reviewer', href: grant_reviewers_path(@grant)
        end
      end
    end
  end


  # does not show index on new submissions

  # does show index on submission role_editor

  # does show add remove link on editable submissions
  # does not





# change show review page to show applicants instead of submitter





end