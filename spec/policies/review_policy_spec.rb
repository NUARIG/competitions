require 'rails_helper'

RSpec.describe ReviewPolicy, type: :policy do
  subject { described_class.new(user, review) }

  let(:grant)             { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:submission)        { grant.submissions.first }
  let(:review)            { create(:incomplete_review, assigner: grant.administrators.first,
                                    reviewer: grant.reviewers.first,
                                    submission: grant.submissions.first) }
  let(:submitter)         { submission.submitter}
  let(:logged_in_user)    { create(:saml_user) }

  context 'with a system admin user' do
    let(:user) { create(:system_admin_saml_user) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:opt_out) }
  end

  context 'with a grant admin user' do
    let(:user) { GrantPermission.where(grant: grant, role: 'admin').first.user }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:opt_out) }
  end

  context 'with a grant editor user' do
    let(:user) { GrantPermission.where(grant: grant, role: 'editor').first.user }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:opt_out) }
  end

  context 'with a grant viewer user' do
    let(:user) { GrantPermission.where(grant: grant, role: 'viewer').first.user }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:opt_out) }
  end

  context 'with an assigned grant reviewer user' do
    let(:user) { review.reviewer }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.to permit_action(:opt_out) }
  end

  context 'with an unassigned grant reviewer user' do
    let(:other_grant_reviewer) { create(:grant_reviewer, grant: grant) }
    let(:user)                 { other_grant_reviewer.reviewer}

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:opt_out) }
  end

  context 'with an submitter user' do
    let(:user) { submission.submitter }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:opt_out) }
  end

  context 'with an logged in user with no role or submission' do
    let(:user) { create(:saml_user) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:opt_out) }
  end

  describe 'other grant users' do
    let(:other_grant) { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }

    context 'with an editor on another grant' do
      let(:user)        { other_grant.administrators.first }

      it { is_expected.not_to permit_action(:index) }
      it { is_expected.not_to permit_action(:new) }
      it { is_expected.not_to permit_action(:create) }
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:destroy) }
      it { is_expected.not_to permit_action(:opt_out) }
    end

    context 'with a reviewer on another grant' do
      let(:user)        { other_grant.reviewers.first }

      it { is_expected.not_to permit_action(:index) }
      it { is_expected.not_to permit_action(:new) }
      it { is_expected.not_to permit_action(:create) }
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:destroy) }
      it { is_expected.not_to permit_action(:opt_out) }
    end
  end
end
