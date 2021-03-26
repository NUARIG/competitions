# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GrantPermissionsHelper, type: :helper do
  let!(:grant) { create(:published_open_grant_with_users) }

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
end
