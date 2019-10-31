require 'rails_helper'

describe BannerPolicy do
  # This file only tests the permissions based on role in pundit.
  # Permissions based on state changes are handled in system specs.

  context 'policy scope tests on index' do
    let(:scope) { Pundit.policy_scope!(user, Banner) }

    before(:each) do
      @banner                 = create(:banner)
      @invisible_banner       = create(:invisible_banner)
      @long_banner            = create(:long_banner)
      @invisible_long_banner  = create(:invisible_long_banner)
    end

    context 'Normal user' do
      let(:user) { create(:user) }

      it 'allows system_admin access to all banners' do
        expect(scope.to_a).not_to include(@banner)
        expect(scope.to_a).not_to include(@invisible_banner)
        expect(scope.to_a).not_to include(@long_banner)
        expect(scope.to_a).not_to include(@invisible_long_banner)
      end
    end

    context 'system_admin user' do
      let(:user) { create(:system_admin_user) }

      it 'allows system_admin access to all banners' do
        expect(scope.to_a).to include(@banner)
        expect(scope.to_a).to include(@invisible_banner)
        expect(scope.to_a).to include(@long_banner)
        expect(scope.to_a).to include(@invisible_long_banner)
      end
    end
  end

  context 'policy tests on restful actions besides index' do
    subject { described_class.new(user, banner)}
    let(:banner) { create(:banner) }

    context 'with a system admin user' do
      let(:user) { create(:system_admin_user) }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end

    context 'with a normal user' do
      let(:user) { create(:user) }

      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end
end
