# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GrantPermissionsHelper, type: :helper do
  let!(:grant)            { create(:published_open_grant_with_users) }
  let(:admin_permission)  { grant.grant_permissions.find_by(role: 'admin') }
  let(:editor_permission) { grant.grant_permissions.find_by(role: 'editor') }
  let(:viewer_permission) { grant.grant_permissions.find_by(role: 'viewer') }

  context 'admin_submission_notification_emails' do
    context 'no submission_notifiction admins' do
      it 'returns [] when no admins' do
        expect(admin_submission_notification_emails(grant: grant)).to be_empty
      end
    end

    context 'one submission_notifiction admin' do
      it 'returns array with one email' do
        grant.grant_permissions.role_admin.first.update(submission_notification: true)
        expect(admin_submission_notification_emails(grant: grant)).to eql [grant.admins.first.email]
      end
    end

    context 'multiple submission_notifiction admins' do
      it 'returns array with all emails' do
        grant.grant_permissions.role_admin.first.update(submission_notification: true)
        grant.grant_permissions.role_viewer.first.update(submission_notification: true)
        expect(admin_submission_notification_emails(grant: grant)).to eql [grant.admins.first.email, grant.viewers.first.email]
      end
    end
  end

  context 'role_can_be_deleted?' do
    context 'admins' do
      it 'returns false for the only admin on a grant' do
        expect(role_can_be_deleted?(user_permission: admin_permission, grant_admins: grant.admins)).to be false
      end

      it 'returns true when there is more than one admin on the grant' do
        editor_permission.update(role: 'admin')
        expect(role_can_be_deleted?(user_permission: admin_permission, grant_admins: grant.admins)).to be true
      end
    end

    it 'returns true for editor role' do
      expect(role_can_be_deleted?(user_permission: editor_permission, grant_admins: grant.admins)).to be true
    end

    it 'returns true for viewer role' do
      expect(role_can_be_deleted?(user_permission: viewer_permission, grant_admins: grant.admins)).to be true
    end
  end
end
