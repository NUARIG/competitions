# frozen_string_literal: true

require 'rails_helper'
include ApplicationHelper
include UsersHelper

RSpec.describe 'GrantPermissions', type: :system, js: true do
  before(:each) do
    @grant        = create(:grant_with_users)
    @invalid_user = create(:saml_user)

    @grant_admin  = @grant.grant_permissions.role_admin.first.user
    @grant_editor = @grant.grant_permissions.role_editor.first.user
    @grant_viewer = @grant.grant_permissions.role_viewer.first.user

    @grant_admin_role  = @grant.grant_permissions.role_admin.first
    @grant_editor_role = @grant.grant_permissions.role_editor.first
    @grant_viewer_role = @grant.grant_permissions.role_viewer.first

    @unassigned_user   = create(:saml_user)
    @select2_user      = create(:saml_user, email: 'select2_user@school.edu')
  end

  describe 'grant editor user' do
    before(:each) do
      login_as(@grant_editor, scope: :saml_user)
      visit grant_grant_permissions_path(@grant)
    end

    context '#index' do
      scenario 'includes link to add permission' do
        expect(page).to have_link 'Grant access to another user', href: new_grant_grant_permission_path(@grant)
      end

      scenario 'includes edit link, excludes delete link' do
        expect(page).to have_link 'Edit',   href: edit_grant_grant_permission_path(@grant, @grant_admin_role)
        expect(page).not_to have_link 'Delete', href: grant_grant_permission_path(@grant, @grant_admin_role)
        expect(page).to have_link 'Edit',   href: edit_grant_grant_permission_path(@grant, @grant_editor_role)
        expect(page).not_to have_link 'Delete', href: grant_grant_permission_path(@grant, @grant_editor_role)
        expect(page).to have_link 'Edit',   href: edit_grant_grant_permission_path(@grant, @grant_viewer_role)
        expect(page).not_to have_link 'Delete', href: grant_grant_permission_path(@grant, @grant_viewer_role)
      end

      scenario 'includes information in grant admin table row' do
        within("tr#grant_permission_#{@grant_admin_role.id}") do
          expect(page).to have_content(full_name(@grant_admin))
          expect(page).to have_content(@grant_admin_role.role.capitalize)
          expect(page).to have_content(on_off_boolean(@grant.grant_permissions.role_admin.first.submission_notification))
        end
      end
    end

    context '#edit' do
      scenario 'removes edit links for user who changes their permission to viewer' do
        visit edit_grant_grant_permission_path(@grant, @grant_editor_role)
        select('Viewer', from: 'grant_permission[role]')
        click_button 'Update'
        expect(page).not_to have_link('Edit', href: edit_grant_grant_permission_path(@grant, @grant_editor_role))
        expect(page).not_to have_link('Delete', href: grant_grant_permission_path(@grant, @grant_editor_role))
        assert_equal grant_grant_permissions_path(@grant), current_path
      end

      scenario 'existing grant_permission_editor can be assigned admin role' do
        visit edit_grant_grant_permission_path(@grant, @grant_editor_role)
        select('Admin', from: 'grant_permission[role]')
        click_button 'Update'
        expect(page).to have_content "#{full_name(@grant_editor)}'s permission was changed to 'admin' for this grant."
      end

      scenario 'last grant_permission_admin cannot be assigned a different role' do
        visit edit_grant_grant_permission_path(@grant, @grant_admin_role)
        select('Viewer', from: 'grant_permission[role]')
        click_button 'Update'
        expect(page).to have_content 'There must be at least one admin on the grant'
        expect(@grant_admin_role.role).to eql('admin')
      end

      context 'notifications' do
        scenario 'can change notification level for submissions' do
          visit edit_grant_grant_permission_path(@grant, @grant_admin_role)
          expect(@grant_admin_role.submission_notification).to eql false
          find(:css, "#grant_permission_submission_notification").set(true)
          click_button 'Update'
          visit edit_grant_grant_permission_path(@grant, @grant_admin_role)
          @grant_admin_role.reload
          expect(@grant_admin_role.submission_notification).to eql true
        end
      end
    end

    context '#new' do
      before(:each) do
        visit new_grant_grant_permission_path(@grant.id)
      end

      scenario 'assigned grant_permission does not appear in select' do
        expect(page.all('select#grant_permission_user_id option').map(&:value)).not_to include(@grant_admin.id.to_s)
      end

      scenario 'requires a selected user' do
        visit new_grant_grant_permission_path(@grant.id)
        select('Editor', from:'grant_permission[role]')
        click_button 'Save'
        expect(page).to have_content('User must be selected.')
      end

      scenario 'requires a selected user' do
        select2(@unassigned_user.email, from: 'Email Address', search: true)
        click_button 'Save'
        expect(page).to have_content('Role must be selected.')
      end

      scenario 'unassigned user can be granted a role' do
        select2(@unassigned_user.email, from: 'Email Address', search: true)
        select('Editor', from:'grant_permission[role]')
        click_button 'Save'
        expect(page).to have_content "#{full_name(@unassigned_user)} was granted 'editor'"
      end

      scenario 'new grant permission defaults to false for submission notification' do
        select2(@unassigned_user.email, from: 'Email Address', search: true)
        select('Editor', from:'grant_permission[role]')
        click_button 'Save'
        expect(GrantPermission.last.submission_notification).to eql false
      end

      scenario 'new grant permission can be set to true for submission notification' do
        select2(@unassigned_user.email, from: 'Email Address', search: true)
        select('Editor', from:'grant_permission[role]')
        find(:css, "#grant_permission_submission_notification").set(true)
        click_button 'Save'
        expect(GrantPermission.last.submission_notification).to eql true
      end

      context 'select2 search' do
        scenario 'select2 dropdown includes unassigned emails' do
          select2 @select2_user.email, from: 'Email Address', search: true
          select2 @select2_user.email, from: 'Email Address', search: 'select2'
        end

        scenario 'select2 displays search email, if exists' do
          select2_open label: 'Email Address'
          select2_search 'select2_user', from: 'Email Address'
          expect(page).to have_content(@select2_user.email)
        end

        scenario 'select2 requires at least one character entered' do
          select2_open label: 'Email Address'
          expect(page).to have_content('Please enter 3 or more characters')
        end

        scenario 'select2 limits dropdown options with' do
          select2_open label: 'Email Address'
          select2_search 'zzzzzzzzzz', from: 'Email Address'
          expect(page).to have_content('No results found')
          expect(page).to have_select('grant_permission_user_id', :with_options => [])
        end
      end
    end
  end

  describe 'grant viewer user' do
    before(:each) do
      login_as(@grant_viewer, scope: :saml_user)
    end

    context '#index' do
      scenario 'does not include link to add permission' do
        visit grant_grant_permissions_path(@grant)
        expect(page).not_to have_link 'Add new permission', href: new_grant_grant_permission_path(@grant)
      end

      scenario 'can visit the permissions index' do
        visit grant_grant_permissions_path(@grant)
        expect(page).not_to have_content authorization_error_text
      end

      scenario 'does not include edit and delete links' do
        visit grant_grant_permissions_path(@grant)
        expect(page).not_to have_link edit_grant_grant_permission_path(@grant, @grant_admin_role)
        expect(page).not_to have_link grant_grant_permission_path(@grant, @grant_admin_role)
        expect(page).not_to have_link edit_grant_grant_permission_path(@grant, @grant_editor_role)
        expect(page).not_to have_link grant_grant_permission_path(@grant, @grant_editor_role)
        expect(page).not_to have_link edit_grant_grant_permission_path(@grant, @grant_viewer_role)
        expect(page).not_to have_link grant_grant_permission_path(@grant, @grant_viewer_role)
      end
    end

    context '#edit' do
      scenario 'cannot access the edit page' do
        visit edit_grant_grant_permission_path(@grant, @grant_admin_role)
        expect(page).to have_content authorization_error_text
      end
    end
  end

  describe 'unauthorized_user' do
    before(:each) do
      @unauthorized_user = create(:saml_user)

      @grant2            = create(:grant)
      @grant2_user       = create(:admin_grant_permission, grant: @grant2,
                                                           user: @unauthorized_user)

      login_as(@unauthorized_user, scope: :saml_user)
    end

    scenario 'cannot access index page' do
      visit grant_grant_permissions_path(@grant)
      expect(page).to have_content authorization_error_text
    end

    scenario 'cannot access the edit page' do
      visit edit_grant_grant_permission_path(@grant, @grant_admin_role)
      expect(page).to have_content authorization_error_text
    end
  end
end
