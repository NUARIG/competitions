require 'rails_helper'

describe PanelPolicy do
  subject { described_class.new(user, grant.panel) }

  let(:grant)       { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }

  let(:other_grant) { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }


  context 'logged in user with no permissions' do
    let(:user) { create(:user) }

    it { is_expected.not_to permit_actions(%i[show edit update]) }
  end

  context 'system_admin_user' do
    let(:user)  { create(:user, system_admin: true) }

    it { is_expected.to permit_actions(%i[show edit update]) }
  end

  context 'grant_admin' do
    let(:user)  { grant.admins.first }

    it { is_expected.to permit_actions(%i[show edit update]) }
  end

  context 'grant_editor' do
    let(:user)  { grant.editors.first }

    it { is_expected.to permit_actions(%i[show edit update]) }
  end

  context 'grant_viewer' do
    let(:user)  { grant.viewers.first }

    it { is_expected.to permit_action(:show)  }
    it { is_expected.not_to permit_action(:edit)   }
    it { is_expected.not_to permit_action(:update) }
  end

  context 'grant_reviewer' do
    let(:user)  { grant.reviewers.first }

    it { is_expected.to permit_action(:show)  }
    it { is_expected.not_to permit_action(:edit)   }
    it { is_expected.not_to permit_action(:update) }
  end

  context 'other grant_admin' do
    let(:user) { other_grant.admins.first }

    it { is_expected.not_to permit_actions(%i[show edit update]) }
  end

  context 'anonymous user' do
    let(:user) { nil }

    it { is_expected.not_to permit_actions(%i[show edit update]) }
  end

  context 'applicant' do
    let(:user) { grant.applicants.first }

    it { is_expected.not_to permit_actions(%i[show edit update]) }
  end
end
