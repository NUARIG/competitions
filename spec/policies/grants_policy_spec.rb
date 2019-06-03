require 'rails_helper'

describe GrantPolicy do


  # These still need to have the index method / scope accounted for.
  context 'published, not yet open grant without submissions' do
    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
        let(:grant) { create(:published_not_yet_open_grant_with_users) }
        let(:user) { grant.grant_permissions.role_admin.first.user }
        subject { described_class.new(user, grant)}

        it { is_expected.to permit_action(:show) }
        it { is_expected.to permit_action(:new) }
        it { is_expected.to permit_action(:create) }

        it { is_expected.to forbid_action(:edit) }
        it { is_expected.to forbid_action(:update) }
        it { is_expected.to forbid_action(:destroy) }
      end

      context 'grant editor user on the grant' do
      end

      context 'grant viewer user on the grant' do
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
      end

      context 'user' do
        let(:user) { create(:user) }
        let(:grant) { create(:published_not_yet_open_grant) }
        subject { described_class.new(user, grant)}

        it { is_expected.to forbid_action(:show) }
        it { is_expected.to forbid_action(:new) }
        it { is_expected.to forbid_action(:edit) }
        it { is_expected.to forbid_action(:create) }
        it { is_expected.to forbid_action(:update) }
        it { is_expected.to forbid_action(:destroy) }
      end
    end
  end

  context 'draft, not yet open grant without submissions' do
    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
      end

      context 'grant editor user on the grant' do
      end

      context 'grant viewer user on the grant' do
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
      end

      context 'user' do
      end
    end
  end

  context 'published, open grant without submissions' do
    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
      end

      context 'grant editor user on the grant' do
      end

      context 'grant viewer user on the grant' do
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
      end

      context 'user' do
        let(:user) { create(:user) }
        let(:grant) { create(:published_open_grant) }
        subject { described_class.new(user, grant)}

        it { is_expected.to permit_action(:show) }

        it { is_expected.to forbid_action(:new) }
        it { is_expected.to forbid_action(:edit) }
        it { is_expected.to forbid_action(:create) }
        it { is_expected.to forbid_action(:update) }
        it { is_expected.to forbid_action(:destroy) }
      end
    end
  end

  context 'draft, open grant without submissions' do
    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
        let(:grant) { create(:draft_grant_with_users)}
        let(:user) { grant.grant_permissions.role_admin.first.user }
        subject { described_class.new(user, grant)}

        it { is_expected.to permit_action(:show) }
        it { is_expected.to permit_action(:new) }
        it { is_expected.to permit_action(:edit) }
        it { is_expected.to permit_action(:create) }
        it { is_expected.to permit_action(:update) }
        it { is_expected.to permit_action(:destroy) }
      end

      context 'grant editor user on the grant' do
      end

      context 'grant viewer user on the grant' do
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
      end

      context 'user' do
        let(:user) { create(:user) }
        let(:grant) { create(:draft_grant) }
        subject { described_class.new(user, grant)}

        it { is_expected.to forbid_action(:show) }
        it { is_expected.to forbid_action(:new) }
        it { is_expected.to forbid_action(:edit) }
        it { is_expected.to forbid_action(:create) }
        it { is_expected.to forbid_action(:update) }
        it { is_expected.to forbid_action(:destroy) }
      end
    end
  end

  context 'published, completed grant without submissions' do
    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
      end

      context 'grant editor user on the grant' do
      end

      context 'grant viewer user on the grant' do
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
      end

      context 'user' do
        let(:user) { create(:user) }
        let(:grant) { create(:completed_grant_with_users) }
        subject { described_class.new(user, grant)}

        it { is_expected.to forbid_action(:show) }
        it { is_expected.to forbid_action(:new) }
        it { is_expected.to forbid_action(:edit) }
        it { is_expected.to forbid_action(:create) }
        it { is_expected.to forbid_action(:update) }
        it { is_expected.to forbid_action(:destroy) }
      end
    end
  end

  context 'draft, completed grant without submissions' do
    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
      end

      context 'grant editor user on the grant' do
      end

      context 'grant viewer user on the grant' do
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
      end

      context 'user' do
      end
    end
  end

  # The specs below require submission and form factories before they will work.

  context 'published, not yet open grant with submissions' do
    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
      end

      context 'grant editor user on the grant' do
      end

      context 'grant viewer user on the grant' do
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
      end

      context 'user' do
      end
    end
  end

  context 'draft, not yet open grant with submissions' do
    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
      end

      context 'grant editor user on the grant' do
      end

      context 'grant viewer user on the grant' do
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
      end

      context 'user' do
      end
    end
  end

  context 'published, open grant with submissions' do
    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
      end

      context 'grant editor user on the grant' do
      end

      context 'grant viewer user on the grant' do
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
      end

      context 'user' do
      end
    end
  end

  context 'draft, open grant with submissions' do
    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
      end

      context 'grant editor user on the grant' do
      end

      context 'grant viewer user on the grant' do
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
      end

      context 'user' do
      end
    end
  end

  context 'published, completed grant with submissions' do
    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
      end

      context 'grant editor user on the grant' do
      end

      context 'grant viewer user on the grant' do
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
      end

      context 'user' do
      end
    end
  end

  context 'draft, completed grant with submissions' do
    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
      end

      context 'grant editor user on the grant' do
      end

      context 'grant viewer user on the grant' do
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
      end

      context 'user' do
      end
    end
  end
end
