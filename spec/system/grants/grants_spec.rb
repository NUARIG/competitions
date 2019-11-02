# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'Grants', type: :system do
  def authorization_error_text
    I18n.t('pundit.default')
  end

  describe 'Index', js: true do
    before(:each) do
      @grant                  = create(:grant_with_users)
      @inaccessible_grant     = create(:grant_with_users)
      @soft_deleted_grant     = create(:grant_with_users, deleted_at: 1.hour.ago)
      @admin_user             = @grant.grant_permissions.role_admin.first.user

      @draft_grant            = create(:draft_grant)
      draft_grant_permission  = create(:admin_grant_permission, user: @admin_user, grant: @draft_grant)

      login_as(@admin_user)
      visit grants_path
    end

    scenario 'does not display soft_deleted grant' do
      expect(page).not_to have_content(@soft_deleted_grant.name)
    end

    scenario 'displays only public grants for grant_admins' do
      expect(page).to have_link('Edit', href: edit_grant_path(@grant))

      expect(page).not_to have_link('Edit', href: edit_grant_path(@inaccessible_grant))
      expect(page).not_to have_link('Delete', href: grant_path(@inaccessible_grant))
      expect(page).not_to have_link('Delete', href: grant_path(@grant))
      expect(page).not_to have_link('Edit', href: edit_grant_path(@draft_grant))
      expect(page).not_to have_link('Delete', href: grant_path(@draft_grant))
    end
  end

  describe 'Edit', js: true do
    before(:each) do
      @grant          = create(:grant_with_users)
      @admin_user     = @grant.grant_permissions.role_admin.first.user

      login_as(@admin_user)
      visit edit_grant_path(@grant)
    end

    scenario 'date fields edited with datepicker are properly formatted' do
      tomorrow = (Date.current + 1.day).to_s

      expect(page).to have_field('grant_publish_date', with: @grant.publish_date)
      page.execute_script("$('#grant_publish_date').fdatepicker('setDate',new Date('#{tomorrow}'))")
      click_button 'Update'

      expect(@grant.reload.publish_date.to_s).to eql(tomorrow)
    end

    scenario 'versioning tracks whodunnit', versioning: true do
      expect(PaperTrail).to be_enabled
      fill_in 'grant_name', with: 'New_Name'
      click_button 'Update'

      expect(page).to have_content 'Grant was successfully updated.'
      expect(@grant.versions.last.whodunnit).to eql(@admin_user.id)
    end

    scenario 'invalid submission', versioning: true do
      page.fill_in 'Close Date', with: (@grant.submission_open_date - 1.day)
      click_button 'Update'
      expect(page).to have_content 'Submission Close Date must be after the opening date for submissions.'
    end
  end

  describe 'New', js: true do
    before(:each) do
      @grant        = build(:new_grant)
      @user         = create(:user, system_admin: true)
      login_as(@user)

      visit new_grant_path

      page.fill_in 'Name', with: @grant.name
      page.fill_in 'Short Name', with: @grant.slug
      # TODO: Figure out rspec / trix
      #   page.find('grant_rfa').click.set(@grant.grant_rfa)
      #   page.find('review_guidance').click.set(@grant.review_guidance)
      page.fill_in 'Publish Date', with: @grant.publish_date
      page.fill_in 'Open Date', with: @grant.submission_open_date
      page.fill_in 'Close Date', with: @grant.submission_close_date
      page.fill_in 'Maximum Reviewers / Submission', with: @grant.max_reviewers_per_submission
      page.fill_in 'Maximum Submissions / Reviewer', with: @grant.max_submissions_per_reviewer
      page.fill_in 'Review Open Date', with: @grant.review_open_date
      page.fill_in 'Review Close Date', with: @grant.review_close_date
      page.fill_in 'Panel Location', with: @grant.panel_location
    end

    scenario 'valid form submission creates permissions' do
      click_button 'Save as Draft'
      grant = Grant.last
      expect(grant.name).to eql(@grant.name)
      expect(page.current_path).to eq(grant_grant_permissions_path(grant))
      expect(grant.state).to eql('draft')
      expect(page).to have_content 'Grant saved'
      click_link('Permissions', href: grant_grant_permissions_path(grant).to_s)
      expect(page).to have_content full_name(@user)
      expect(grant.editors.count).to eql 1
      expect(@user.grant_permissions.where(grant: grant).first.role).to eql 'admin'
    end

    scenario 'invalid form submission does not create permissions' do
      grant_permission_count          = GrantPermission.all.count

      page.fill_in 'Close Date', with: (@grant.submission_open_date - 1.day)
      click_button 'Save as Draft'
      expect(page).to have_content 'Submission Close Date must be after the opening date for submissions.'
      expect(GrantPermission.all.count).to eql(grant_permission_count)
    end
  end

  describe 'Duplicate', js: true do
    before(:each) do
      @grant          = create(:grant_with_users)
      @admin_user     = @grant.grant_permissions.role_admin.first.user

      login_as(@admin_user)
    end

    scenario 'new_grant_duplicate does not create a new grant' do
      visit edit_grant_path(@grant)
      expect do
        click_link('Duplicate', href: new_grant_duplicate_path(@grant))
        expect(page).to have_content "Information from #{@grant.name} has been copied below."
      end.not_to change{Grant.count}
    end

    scenario 'clears dates' do
      visit edit_grant_path(@grant)
      click_link('Duplicate', href: new_grant_duplicate_path(@grant))
      expect(page.find_field('grant_publish_date').value).to eql ''
      expect(page.find_field('grant_submission_open_date').value).to eql ''
      expect(page.find_field('grant_submission_close_date').value).to eql ''
      expect(page.find_field('grant_review_open_date').value).to eql ''
      expect(page.find_field('grant_review_close_date').value).to eql ''
    end

    scenario 'duplicated grant requires a new title and short name' do
      visit edit_grant_path(@grant)
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

    scenario 'invalid grant.id redirects to home' do
      visit new_grant_duplicate_path(Grant.last.id + 1)
      expect(page).to have_content('Grant not found')
      assert_equal grants_path, current_path
    end
  end

  describe 'SoftDelete', js: true do
    before(:each) do
      @grant          = create(:grant_with_users)
      @admin_user     = @grant.grant_permissions.role_admin.first.user

      login_as(@admin_user)
    end

    pending 'published grant with submissions cannot be deleted' do
      fail '#TODO: grant.submissions.count.zero?'
    end

    pending 'published grant without submissions can be deleted' do
      fail '#TODO: grant.submissions.count.zero?'
    end

    pending 'delete button hidden when not soft_deletable' do
      fail '#TODO: logic to display the delete button'
    end

    scenario 'draft grant can be soft deleted' do
      @grant.update_attributes!(state: 'draft')
      visit edit_grant_path(@grant.id)
      click_link 'Delete'
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content 'Grant was successfully deleted.'
    end

    scenario 'completed grant cannot be soft deleted' do
      @grant.update_attributes!(state: 'completed')
      visit edit_grant_path(@grant.id)
      click_link 'Delete'
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content 'Completed grant may not be deleted'
    end
  end

  describe 'Policy', js: true do
    before(:each) do
      @grant          = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
      @invalid_user   = create(:user)
      @grant_viewer   = @grant.grant_permissions.role_viewer.first.user
      @grant_editor   = @grant.grant_permissions.role_editor.first.user
      @grant_admin    = @grant.grant_permissions.role_admin.first.user
      @grant_reviewer = @grant.reviewers.first
      @system_admin = create(:system_admin_user)

      @grant_permission   = @grant.grant_permissions.role_editor.first
    end

    context 'anoymous user' do
      scenario 'can view published open grant' do
        visit grant_path(@grant)
        expect(page).not_to have_content authorization_error_text
        expect(page).to have_link 'Apply Now'
      end

      scenario 'can view published not yet open grant' do
        @grant.update_attribute(:submission_open_date, DateTime.tomorrow)
        visit grant_path(@grant)
        expect(page).not_to have_content authorization_error_text
        expect(page).to have_text 'This Grant is Not Currently Accepting Submissions'
      end

      scenario 'cannot view draft grant' do
        @grant.update_attribute(:state, 'draft')
        visit grant_path(@grant)
        expect(page).to have_content authorization_error_text
      end

      scenario 'cannot view closed grant' do
        @grant.update_attribute(:submission_close_date, DateTime.yesterday)
        visit grant_path(@grant)
        expect(page).to have_content authorization_error_text
      end

    end

    context 'system admin' do
      before(:each) do
        login_as @system_admin
      end

      scenario 'can access edit pages' do
        visit new_grant_path
        expect(page).not_to have_content authorization_error_text
        visit edit_grant_path(@grant)
        expect(page).not_to have_content authorization_error_text
        visit grant_grant_permissions_path(@grant)
        expect(page).not_to have_content authorization_error_text
        visit edit_grant_grant_permission_path(@grant, @grant_permission)
        expect(page).not_to have_content authorization_error_text
        visit new_grant_duplicate_path(@grant)
        expect(page).not_to have_content authorization_error_text
      end

      scenario 'can duplicate a grant' do
        visit new_grant_duplicate_path(@grant)
        expect(page).not_to have_content authorization_error_text
      end
    end

    context 'invalid user' do
      before(:each) do
        login_as @invalid_user
      end

      scenario 'user without access cannot access edit pages' do
        visit new_grant_path
        expect(page).to have_content authorization_error_text
        visit edit_grant_path(@grant)
        expect(page).to have_content authorization_error_text
        visit grant_grant_permissions_path(@grant)
        expect(page).to have_content authorization_error_text
        visit edit_grant_grant_permission_path(@grant, @grant_permission)
        expect(page).to have_content authorization_error_text
        visit new_grant_duplicate_path(@grant)
        expect(page).to have_content authorization_error_text
      end
    end

    context 'grant editor' do
      before(:each) do
        login_as @grant_editor
      end

      scenario 'can access show page' do
        visit grant_path(@grant)
        expect(page).not_to have_content authorization_error_text
      end

      scenario 'can access edit page' do
        visit edit_grant_path(@grant)
        expect(page).not_to have_content authorization_error_text
      end

      scenario 'cannot duplicate a grant' do
        visit new_grant_duplicate_path(@grant)
        expect(page).to have_content authorization_error_text
      end

      scenario 'can access grant_permissions page' do
        visit grant_grant_permissions_path(@grant)
        expect(page).not_to have_content authorization_error_text
      end
    end

    context 'grant editor who is also grant_creator' do
      before(:each) do
        @grant_editor.update_attribute(:grant_creator, true)
        login_as @grant_editor
      end

      scenario 'can duplicate a grant' do
        visit new_grant_duplicate_path(@grant)
        expect(page).not_to have_content authorization_error_text
      end
    end

    context 'grant viewer' do
      before(:each) do
        login_as @grant_viewer
      end

      scenario 'can access show page' do
        visit grant_path(@grant)
        expect(page).not_to have_content authorization_error_text
      end

      scenario 'cannot access edit page' do
        visit edit_grant_path(@grant)
        expect(page).to have_content authorization_error_text
      end

      scenario 'cannot duplicate a grant' do
        visit new_grant_duplicate_path(@grant)
        expect(page).to have_content authorization_error_text
      end

      pending 'can access grant_permissions page' do
        fail 'grant_viewer to be deleted'
        visit grant_grant_permissions_path(@grant)
        expect(page).not_to have_content authorization_error_text
      end

      scenario 'cannot edit a grant_permission' do
        visit edit_grant_grant_permission_path(@grant, @grant_permission)
        expect(page).to have_content authorization_error_text
      end
    end

    context 'grant reviewer' do
      before(:each) do
        login_as @grant_reviewer
      end

      scenario 'can view grant in draft mode' do
        @grant.update_attribute(:state, 'draft')
        visit grant_path(@grant)
        expect(page).not_to have_content authorization_error_text
      end

      scenario 'can view closed grant' do
        @grant.update_attribute(:submission_close_date, DateTime.yesterday)
        visit grant_path(@grant)
        expect(page).not_to have_content authorization_error_text
      end

      scenario 'cannot access edit pages' do
        visit edit_grant_path(@grant)
        expect(page).to have_content authorization_error_text
        visit grant_grant_permissions_path(@grant)
        expect(page).to have_content authorization_error_text
        visit edit_grant_grant_permission_path(@grant, @grant_permission)
        expect(page).to have_content authorization_error_text
        visit new_grant_duplicate_path(@grant)
        expect(page).to have_content authorization_error_text
      end
    end
  end
end
