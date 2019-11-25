# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'GrantsDuplicate', type: :system, js: true do
  describe 'Duplicate' do
    before(:each) do
      @grant          = create(:grant_with_users)
      @admin_user     = @grant.grant_permissions.role_admin.first.user
      @editor_user    = @grant.grant_permissions.role_editor.first.user
      @viewer_user    = @grant.grant_permissions.role_viewer.first.user
    end

    context 'admin' do
      before(:each) do
        @admin_user.update_attribute(:grant_creator, false)
        login_as(@admin_user)
      end

      context 'who is not a grant_creator' do
        scenario 'does not see the Duplicate link in header' do
          visit edit_grant_path(@grant)
          expect(page).not_to have_link 'Duplicate', href: new_grant_duplicate_path(@grant)
        end
      end

      context 'who is a grant_creator' do
        before(:each) do
          @admin_user.update_attribute(:grant_creator, true)
          visit edit_grant_path(@grant)
        end

        scenario 'sees the Duplicate link in header' do
          visit edit_grant_path(@grant)
          expect(page).to have_link 'Duplicate', href: new_grant_duplicate_path(@grant)
        end

        scenario 'new_grant_duplicate does not create a new grant' do
          expect do
            click_link('Duplicate', href: new_grant_duplicate_path(@grant))
            expect(page).to have_content "Information from #{@grant.name} has been copied below."
          end.not_to change{Grant.count}
        end

        scenario 'clears dates' do
          click_link('Duplicate', href: new_grant_duplicate_path(@grant))
          expect(page.find_field('grant_publish_date').value).to eql ''
          expect(page.find_field('grant_submission_open_date').value).to eql ''
          expect(page.find_field('grant_submission_close_date').value).to eql ''
          expect(page.find_field('grant_review_open_date').value).to eql ''
          expect(page.find_field('grant_review_close_date').value).to eql ''
        end

        scenario 'duplicated grant requires a new title and short name' do
          click_link('Duplicate', href: new_grant_duplicate_path(@grant))

          page.fill_in 'Short Name', with: @grant.slug
          page.fill_in 'Publish Date', with: @grant.publish_date + 1.day
          page.fill_in 'Open Date', with: @grant.submission_open_date + 1.day
          page.fill_in 'Close Date', with: @grant.submission_close_date + 1.day
          page.fill_in 'Review Open Date', with: @grant.review_open_date + 1.day
          page.fill_in 'Review Close Date', with: @grant.review_close_date + 1.day
          expect do
            click_button('Save as Draft')
          end.not_to change{ Grant.count }

          expect(page).to have_content('Name has already been taken')
          expect(page).to have_content('Short Name has already been taken')
        end

        scenario 'valid duplicate submission creates new grant' do
          click_link('Duplicate', href: new_grant_duplicate_path(@grant))

          page.fill_in 'Name', with: "Updated #{@grant.name}"
          page.fill_in 'Short Name', with: "#{@grant.slug}1"
          page.fill_in 'Publish Date', with: @grant.publish_date + 1.day
          page.fill_in 'Open Date', with: @grant.submission_open_date + 1.day
          page.fill_in 'Close Date', with: @grant.submission_close_date + 1.day
          page.fill_in 'Review Open Date', with: @grant.review_open_date + 1.day
          page.fill_in 'Review Close Date', with: @grant.review_close_date + 1.day

          expect do
            click_button('Save as Draft')
          end.to change{ Grant.count }.by(1).and change{ GrantPermission.count}.by(@grant.grant_permissions.count)
          expect(page).to have_content('Current Publish Status: Draft')
        end

        scenario 'invalid grant.id redirects home' do
          visit new_grant_duplicate_path(Grant.last.id + 1)
          expect(page).to have_content('Grant not found')
          assert_equal grants_path, current_path
        end
      end
    end

    context 'editor' do
      before(:each) do
        login_as(@editor_user)
      end

      context 'who is not a grant_creator' do
        before(:each) do
          @editor_user.update_attribute(:grant_creator, false)
        end

        scenario 'does not see the Duplicate link in header' do
          visit edit_grant_path(@grant)
          expect(page).not_to have_link 'Duplicate', href: new_grant_duplicate_path(@grant)
        end
      end

      context 'who is a grant_creator' do
        before(:each) do
          @editor_user.update_attribute(:grant_creator, true)
        end

        scenario 'sees Duplicate link in header' do
          visit edit_grant_path(@grant)
          expect(page).to have_link 'Duplicate', href: new_grant_duplicate_path(@grant)
        end

        scenario 'valid duplicate submission creates new grant' do
          visit edit_grant_path(@grant)
          click_link('Duplicate', href: new_grant_duplicate_path(@grant))

          page.fill_in 'Name', with: "Updated #{@grant.name}"
          page.fill_in 'Short Name', with: "#{@grant.slug}1"
          page.fill_in 'Publish Date', with: @grant.publish_date + 1.day
          page.fill_in 'Open Date', with: @grant.submission_open_date + 1.day
          page.fill_in 'Close Date', with: @grant.submission_close_date + 1.day
          page.fill_in 'Review Open Date', with: @grant.review_open_date + 1.day
          page.fill_in 'Review Close Date', with: @grant.review_close_date + 1.day
          expect do
            click_button('Save as Draft')
          end.to change{ Grant.count }.by(1).and change{ GrantPermission.count}.by(@grant.grant_permissions.count)
          expect(page).to have_content('Current Publish Status: Draft')
        end
      end
    end

    context 'viewer' do
      before(:each) do
        login_as(@viewer_user)
      end

      context 'who is not a grant_creator' do
        before(:each) do
          @viewer_user.update_attribute(:grant_creator, false)
        end

        scenario 'does not see the Duplicate link in header' do
          visit edit_grant_path(@grant)
          expect(page).not_to have_link 'Duplicate', href: new_grant_duplicate_path(@grant)
        end
      end

      context 'who is not a grant_creator' do
        before(:each) do
          @viewer_user.update_attribute(:grant_creator, true)
        end

        scenario 'does not see the Duplicate link in header' do
          visit edit_grant_path(@grant)
          expect(page).not_to have_link 'Duplicate', href: new_grant_duplicate_path(@grant)
        end
      end
    end
  end
end
