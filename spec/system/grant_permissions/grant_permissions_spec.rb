# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'GrantPermissions', type: :system do
  describe 'GrantPermission', js: true do

    before(:each) do
      @grant        = create(:grant_with_users)
      @invalid_user = create(:user)

      @grant_admin  = @grant.grant_permissions.role_admin.first.user
      @grant_editor = @grant.grant_permissions.role_editor.first.user
      @grant_viewer = @grant.grant_permissions.role_viewer.first.user

      @grant_admin_role  = @grant.grant_permissions.role_admin.first
      @grant_editor_role = @grant.grant_permissions.role_editor.first
      @grant_viewer_role = @grant.grant_permissions.role_viewer.first

      @unassigned_user   = create(:user)
    end

    describe 'grant editor user' do
      before(:each) do
        login_as(@grant_editor)
      end

      context '#edit' do
        pending 'removes edit links for user who changes their permission to viewer' do
          fail 'grant_viewer to be deleted'
          visit edit_grant_grant_permission_path(@grant, @grant_editor_role)
          select('viewer', from: 'grant_permission[role]')
          click_button 'Update'
          expect(page).not_to have_link('Edit', href: edit_grant_grant_permission_path(@grant, @grant_editor_role))
          expect(page).not_to have_link('Delete', href: grant_grant_permission_path(@grant, @grant_editor_role))
          assert_equal grant_grant_permissions_path(@grant), current_path
        end

        scenario 'existing grant_permission_editor can be assigned admin role' do
          visit edit_grant_grant_permission_path(@grant, @grant_editor_role)
          select('admin', from: 'grant_permission[role]')
          click_button 'Update'
          expect(page).to have_content "#{full_name(@grant_editor)}'s permission was changed to 'admin' for this grant."
        end

        scenario 'last grant_permission_admin cannot be assigned a different role' do
          visit edit_grant_grant_permission_path(@grant, @grant_admin_role)
          select('viewer', from: 'grant_permission[role]')
          click_button 'Update'
          expect(page).to have_content 'There must be at least one admin on the grant'
          expect(@grant_admin_role.role).to eql('admin')
        end
      end

      context '#new' do
        scenario 'assigned grant_permission does not appear in select' do
          visit new_grant_grant_permission_path(@grant.id)
          expect(page.all('select#grant_permission_user_id option').map(&:value)).not_to include(@grant_admin.id.to_s)
        end

        scenario 'requires a selected user' do
          visit new_grant_grant_permission_path(@grant.id)
          select('editor', from:'grant_permission[role]')
          click_button 'Save'
          expect(page).to have_content('User must be selected.')
        end

        scenario 'requires a selected user' do
          visit new_grant_grant_permission_path(@grant.id)
          select("#{@unassigned_user.email}", from: 'grant_permission[user_id]')
          click_button 'Save'
          expect(page).to have_content('Role must be selected.')
        end

        scenario 'unassigned user can be granted a role' do
          visit new_grant_grant_permission_path(@grant.id)
          select("#{@unassigned_user.email}", from: 'grant_permission[user_id]')
          select('editor', from:'grant_permission[role]')
          click_button 'Save'
          expect(page).to have_content "#{full_name(@unassigned_user)} was granted 'editor'"
        end
      end
    end

    describe 'grant admin user' do
      before(:each) do
        login_as(@grant_admin)
        visit grant_grant_permissions_path(@grant)
      end

      context '#delete' do
        scenario 'cannot delete last admin grant_permission' do
          expect do
            click_link('Delete', href: grant_grant_permission_path(@grant, @grant_admin_role))
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content('This user\'s role cannot be deleted.')
          end.not_to change{@grant.grant_permissions.count}
        end

        scenario 'can delete a grant_permission' do
          expect do
            expect(page).to have_content(full_name(@grant_viewer))
            click_link('Delete', href: grant_grant_permission_path(@grant, @grant_viewer_role))
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content("#{full_name(@grant_viewer)}'s role was removed for this grant.")
          end.to change{@grant.grant_permissions.count}.by (-1)
        end
      end
    end

    describe 'unauthorized_user' do
      before(:each) do
        @unauthorized_user = create(:user)

        @grant2            = create(:grant)
        @grant2_user       = create(:admin_grant_permission, grant: @grant2,
                                                             user: @unauthorized_user)

        login_as(@unauthorized_user)
      end

      scenario 'cannot access index page' do
        visit grant_grant_permissions_path(@grant)
        expect(page).to have_content 'You are not authorized to perform this action.'
      end

      scenario 'cannot access edit page' do
        visit grant_grant_permissions_path(@grant, @grant_admin_user)
        expect(page).to have_content 'You are not authorized to perform this action.'
      end
    end
  end
end
