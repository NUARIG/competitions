require 'rails_helper'

describe GrantPolicy do
  context 'user without permission on published grant' do
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

  context 'user without permission on published not yet open grant' do
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

  context 'user without permission on draft grant' do
    # let(:grant) { Grant.create(publish: true) }
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

  context 'user without permission on completed grant' do
    # let(:grant) { Grant.create(publish: true) }
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

  context 'user with draft grant admin permissions' do
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
end




# # frozen_string_literal: true

# require 'rails_helper'

# describe GrantPolicy do
#   subject { described_class.new(user, grant) }

#   context 'published, open grant without submissions' do
#     let(:grant)        { create(:published_open_grant) }

#     context 'with user having a role on the grant' do
#       context 'grant admin user on the grant' do
#         let(:user) { create(:user) }
#         let(:grant_admin) { create(:admin_grant_permission, grant: grant, user: user) }

#         it { is_expected.to permit_action(:index) }
#         it { is_expected.to permit_action(:show) }

#         it { is_expected.to forbid_action(:new) }
#         it { is_expected.to forbid_action(:create) }
#         it { is_expected.to forbid_action(:edit) }
#         it { is_expected.to forbid_action(:update) }
#         it { is_expected.to forbid_action(:destroy) }
#       end

#       context 'grant editor user on the grant' do
#         let(:user) { create(:user) }
#         let(:grant_editor) { create(:editor_grant_permission, grant: grant, user: user) }

#         it { is_expected.to permit_action(:index) }
#         it { is_expected.to permit_action(:show) }

#         it { is_expected.to forbid_action(:new) }
#         it { is_expected.to forbid_action(:create) }
#         it { is_expected.to forbid_action(:edit) }
#         it { is_expected.to forbid_action(:update) }
#         it { is_expected.to forbid_action(:destroy) }
#       end

#       context 'grant viewer user on the grant' do
#         let(:user) { create(:user) }
#         let(:grant_viewer) { create(:viewer_grant_permission, grant: grant, user: user) }

#         it { is_expected.to permit_action(:index) }
#         it { is_expected.to permit_action(:show) }

#         it { is_expected.to forbid_action(:new) }
#         it { is_expected.to forbid_action(:create) }
#         it { is_expected.to forbid_action(:edit) }
#         it { is_expected.to forbid_action(:update) }
#         it { is_expected.to forbid_action(:destroy) }
#       end
#     end

#     context 'with user not having a role on the grant' do
#       context 'organization admin user' do
#         let(:user) { create(:organization_admin_user) }

#         it { is_expected.to permit_action(:index) }
#         it { is_expected.to permit_action(:show) }
#         it { is_expected.to permit_action(:new) }
#         it { is_expected.to permit_action(:create) }

#         it { is_expected.to forbid_action(:edit) }
#         it { is_expected.to forbid_action(:update) }
#         it { is_expected.to forbid_action(:destroy) }
#       end

#       context 'user' do
#         let(:user) { create(:user) }

#         it { is_expected.to permit_action(:index) }
#         it { is_expected.to permit_action(:show) }

#         it { is_expected.to forbid_action(:new) }
#         it { is_expected.to forbid_action(:create) }
#         it { is_expected.to forbid_action(:edit) }
#         it { is_expected.to forbid_action(:update) }
#         it { is_expected.to forbid_action(:destroy) }
#       end

#       # This only tests the grant_admin on a different grant and
#       # not the editor or viewer, but they would be assumed
#       # to behave the same way.
#       context 'grant_admin on second grant' do
#         let(:user) { create(:user) }
#         let(:grant2)        { create(:published_open_grant) }
#         let(:grant_admin) { create(:admin_grant_permission, grant: grant2, user: user) }

#         it { is_expected.to permit_action(:index) }
#         it { is_expected.to permit_action(:show) }

#         it { is_expected.to forbid_action(:new) }
#         it { is_expected.to forbid_action(:create) }
#         it { is_expected.to forbid_action(:edit) }
#         it { is_expected.to forbid_action(:update) }
#         it { is_expected.to forbid_action(:destroy) }
#       end
#     end
#   end

#   context 'unpublished, open grant without submissions' do
#     let(:grant)        { create(:unpublished_open_grant) }

#     context 'with user having a role on the grant' do
#       context 'grant admin user on the grant' do
#         let(:user) { create(:user) }
#         let(:grant_admin) { create(:admin_grant_permission, grant: grant, user: user) }

#         it { is_expected.to permit_action(:index) }
#         it { is_expected.to permit_action(:show) }
#         it { is_expected.to forbid_action(:new) }
#         it { is_expected.to forbid_action(:create) }
#         it { is_expected.to permit_action(:edit) }
#         it { is_expected.to permit_action(:update) }
#         it { is_expected.to permit_action(:destroy) }
#       end

#       context 'grant editor user on the grant' do
#         let(:user) { create(:user) }
#         let(:grant_editor) { create(:editor_grant_permission, grant: grant, user: user) }

#         it { is_expected.to permit_action(:index) }
#         it { is_expected.to permit_action(:show) }

#         it { is_expected.to forbid_action(:new) }
#         it { is_expected.to forbid_action(:create) }
#         it { is_expected.to permit_action(:edit) }
#         it { is_expected.to permit_action(:update) }
#         it { is_expected.to permit_action(:destroy) }
#       end

#       context 'grant viewer user on the grant' do
#         let(:user) { create(:user) }
#         let(:grant_viewer) { create(:viewer_grant_permission, grant: grant, user: user) }

#         it { is_expected.to permit_action(:index) }
#         it { is_expected.to permit_action(:show) }

#         it { is_expected.to forbid_action(:new) }
#         it { is_expected.to forbid_action(:create) }
#         it { is_expected.to forbid_action(:edit) }
#         it { is_expected.to forbid_action(:update) }
#         it { is_expected.to forbid_action(:destroy) }
#       end
#     end

#     context 'with user not having a role on the grant' do
#       context 'organization admin user' do
#         let(:user) { create(:organization_admin_user) }

#         it { is_expected.to permit_action(:index) }
#         it { is_expected.to permit_action(:show) }
#         it { is_expected.to permit_action(:new) }
#         it { is_expected.to permit_action(:create) }
#         it { is_expected.to permit_action(:edit) }
#         it { is_expected.to permit_action(:update) }
#         it { is_expected.to permit_action(:destroy) }
#       end

#       context 'user' do
#         let(:user) { create(:user) }

#         it { is_expected.to permit_action(:index) }
#         it { is_expected.to permit_action(:show) }

#         it { is_expected.to forbid_action(:new) }
#         it { is_expected.to forbid_action(:create) }
#         it { is_expected.to forbid_action(:edit) }
#         it { is_expected.to forbid_action(:update) }
#         it { is_expected.to forbid_action(:destroy) }
#       end

#       # This only tests the grant_admin on a different grant and
#       # not the editor or viewer, but they would be assumed
#       # to behave the same way.
#       context 'grant_admin on second grant' do
#         let(:user) { create(:user) }
#         let(:grant2)        { create(:unpublished_open_grant) }
#         let(:grant_admin) { create(:admin_grant_permission, grant: grant2, user: user) }

#         it { is_expected.to permit_action(:index) }
#         it { is_expected.to permit_action(:show) }

#         it { is_expected.to forbid_action(:new) }
#         it { is_expected.to forbid_action(:create) }
#         it { is_expected.to forbid_action(:edit) }
#         it { is_expected.to forbid_action(:update) }
#         it { is_expected.to forbid_action(:destroy) }
#       end
#     end
#   end


#   # The specs below require submission and form factories before they will work.

#   # context 'published, open grant with submissions' do
#   #   let(:grant)        { create(:published_open_grant) }

#   #   context 'with user having a role on the grant' do
#   #     context 'grant admin user on the grant' do
#   #       let(:user) { create(:user) }
#   #       let(:grant_admin) { create(:admin_grant_permission, grant: grant, user: user) }

#   #       it { is_expected.to permit_action(:index) }
#   #       it { is_expected.to permit_action(:show) }

#   #       it { is_expected.to forbid_action(:new) }
#   #       it { is_expected.to forbid_action(:create) }
#   #       it { is_expected.to forbid_action(:edit) }
#   #       it { is_expected.to forbid_action(:update) }
#   #       it { is_expected.to forbid_action(:destroy) }
#   #     end

#   #     context 'grant editor user on the grant' do
#   #       let(:user) { create(:user) }
#   #       let(:grant_editor) { create(:editor_grant_permission, grant: grant, user: user) }

#   #       it { is_expected.to permit_action(:index) }
#   #       it { is_expected.to permit_action(:show) }

#   #       it { is_expected.to forbid_action(:new) }
#   #       it { is_expected.to forbid_action(:create) }
#   #       it { is_expected.to forbid_action(:edit) }
#   #       it { is_expected.to forbid_action(:update) }
#   #       it { is_expected.to forbid_action(:destroy) }
#   #     end

#   #     context 'grant viewer user on the grant' do
#   #       let(:user) { create(:user) }
#   #       let(:grant_viewer) { create(:viewer_grant_permission, grant: grant, user: user) }

#   #       it { is_expected.to permit_action(:index) }
#   #       it { is_expected.to permit_action(:show) }

#   #       it { is_expected.to forbid_action(:new) }
#   #       it { is_expected.to forbid_action(:create) }
#   #       it { is_expected.to forbid_action(:edit) }
#   #       it { is_expected.to forbid_action(:update) }
#   #       it { is_expected.to forbid_action(:destroy) }
#   #     end
#   #   end

#   #   context 'with user not having a role on the grant' do
#   #     context 'organization admin user' do
#   #       let(:user) { create(:organization_admin_user) }

#   #       it { is_expected.to permit_action(:index) }
#   #       it { is_expected.to permit_action(:show) }

#   #       it { is_expected.to forbid_action(:new) }
#   #       it { is_expected.to forbid_action(:create) }
#   #       it { is_expected.to forbid_action(:edit) }
#   #       it { is_expected.to forbid_action(:update) }
#   #       it { is_expected.to forbid_action(:destroy) }
#   #     end

#   #     context 'user' do
#   #       let(:user) { create(:user) }

#   #       it { is_expected.to permit_action(:index) }
#   #       it { is_expected.to permit_action(:show) }

#   #       it { is_expected.to forbid_action(:new) }
#   #       it { is_expected.to forbid_action(:create) }
#   #       it { is_expected.to forbid_action(:edit) }
#   #       it { is_expected.to forbid_action(:update) }
#   #       it { is_expected.to forbid_action(:destroy) }
#   #     end

#   #     # This only tests the grant_admin on a different grant and
#   #     # not the editor or viewer, but they would be assumed
#   #     # to behave the same way.
#   #     context 'grant_admin on second grant' do
#   #       let(:user) { create(:user) }
#   #       let(:grant2)        { create(:published_open_grant) }
#   #       let(:grant_admin) { create(:admin_grant_permission, grant: grant2, user: user) }

#   #       it { is_expected.to permit_action(:index) }
#   #       it { is_expected.to permit_action(:show) }

#   #       it { is_expected.to forbid_action(:new) }
#   #       it { is_expected.to forbid_action(:create) }
#   #       it { is_expected.to forbid_action(:edit) }
#   #       it { is_expected.to forbid_action(:update) }
#   #       it { is_expected.to forbid_action(:destroy) }
#   #     end
#   #   end
#   # end

#   # context 'unpublished, open grant with submissions' do
#   #   let(:grant)        { create(:unpublished_open_grant) }

#   #   context 'with user having a role on the grant' do
#   #     context 'grant admin user on the grant' do
#   #       let(:user) { create(:user) }
#   #       let(:grant_admin) { create(:admin_grant_permission, grant: grant, user: user) }

#   #       it { is_expected.to permit_action(:index) }
#   #       it { is_expected.to permit_action(:show) }
#   #       it { is_expected.to forbid_action(:new) }
#   #       it { is_expected.to forbid_action(:create) }
#   #       it { is_expected.to forbid_action(:edit) }
#   #       it { is_expected.to forbid_action(:update) }
#   #       it { is_expected.to forbid_action(:destroy) }
#   #     end

#   #     context 'grant editor user on the grant' do
#   #       let(:user) { create(:user) }
#   #       let(:grant_editor) { create(:editor_grant_permission, grant: grant, user: user) }

#   #       it { is_expected.to permit_action(:index) }
#   #       it { is_expected.to permit_action(:show) }

#   #       it { is_expected.to forbid_action(:new) }
#   #       it { is_expected.to forbid_action(:create) }
#   #       it { is_expected.to forbid_action(:edit) }
#   #       it { is_expected.to forbid_action(:update) }
#   #       it { is_expected.to forbid_action(:destroy) }
#   #     end

#   #     context 'grant viewer user on the grant' do
#   #       let(:user) { create(:user) }
#   #       let(:grant_viewer) { create(:viewer_grant_permission, grant: grant, user: user) }

#   #       it { is_expected.to permit_action(:index) }
#   #       it { is_expected.to permit_action(:show) }

#   #       it { is_expected.to forbid_action(:new) }
#   #       it { is_expected.to forbid_action(:create) }
#   #       it { is_expected.to forbid_action(:edit) }
#   #       it { is_expected.to forbid_action(:update) }
#   #       it { is_expected.to forbid_action(:destroy) }
#   #     end
#   #   end

#   #   context 'with user not having a role on the grant' do
#   #     context 'organization admin user' do
#   #       let(:user) { create(:organization_admin_user) }

#   #       it { is_expected.to permit_action(:index) }
#   #       it { is_expected.to permit_action(:show) }
#   #       it { is_expected.to forbid_action(:new) }
#   #       it { is_expected.to forbid_action(:create) }
#   #       it { is_expected.to forbid_action(:edit) }
#   #       it { is_expected.to forbid_action(:update) }
#   #       it { is_expected.to forbid_action(:destroy) }
#   #     end

#   #     context 'user' do
#   #       let(:user) { create(:user) }

#   #       it { is_expected.to permit_action(:index) }
#   #       it { is_expected.to permit_action(:show) }

#   #       it { is_expected.to forbid_action(:new) }
#   #       it { is_expected.to forbid_action(:create) }
#   #       it { is_expected.to forbid_action(:edit) }
#   #       it { is_expected.to forbid_action(:update) }
#   #       it { is_expected.to forbid_action(:destroy) }
#   #     end

#   #     # This only tests the grant_admin on a different grant and
#   #     # not the editor or viewer, but they would be assumed
#   #     # to behave the same way.
#   #     context 'grant_admin on second grant' do
#   #       let(:user) { create(:user) }
#   #       let(:grant2)        { create(:unpublished_open_grant) }
#   #       let(:grant_admin) { create(:admin_grant_permission, grant: grant2, user: user) }

#   #       it { is_expected.to permit_action(:index) }
#   #       it { is_expected.to permit_action(:show) }

#   #       it { is_expected.to forbid_action(:new) }
#   #       it { is_expected.to forbid_action(:create) }
#   #       it { is_expected.to forbid_action(:edit) }
#   #       it { is_expected.to forbid_action(:update) }
#   #       it { is_expected.to forbid_action(:destroy) }
#   #     end
#   #   end
#   # end
# end
