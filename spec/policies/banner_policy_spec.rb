require 'rails_helper'

describe BannerPolicy do


  context 'policy tests on restful actions besides index' do
    subject { described_class.new(user, banner)}
    let(:banner) { create(:banner) }

    context 'with a system admin user' do
      let(:user) { create(random_system_admin_user) }

      # #Index is handled in the controller.

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end

    context 'with a normal user' do
      let(:user) { create(random_user) }

      it { is_expected.to forbid_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end
end
