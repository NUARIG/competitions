# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Grants', type: :system do
  describe 'published grant', js: true do
    before(:each) do
      @published_grant = create(:grant_with_users_and_questions)
      @admin_user      = @published_grant.grant_users.grant_role_admin.first.user
      @editor_user     = @published_grant.grant_users.grant_role_editor.first.user
    end

    context 'grant admin user' do
      before(:each) do
        login_as(@admin_user)
        visit edit_grant_path(@published_grant)
      end

      scenario 'current status and change status button are shown' do
        expect(page).to have_content 'Current Publish Status: Published'
        expect(page).to have_selector(:link_or_button, 'Switch to Draft')
      end

      scenario 'can change status to draft' do
        click_button 'Switch to Draft'
        expect(page).to have_content 'Current Publish Status: Draft'
        expect(page).to have_content 'Publish status was changed to draft.'
      end
    end

    context 'grant editor user' do
      before(:each) do
        login_as(@editor_user)
        visit edit_grant_path(@published_grant)
      end

      scenario 'current status and change status button are shown' do
        expect(page).to have_content 'Current Publish Status: Published'
        expect(page).to have_selector(:link_or_button, 'Switch to Draft')
      end

      scenario 'can change status to draft' do
        click_button 'Switch to Draft'
        expect(page).to have_content 'Current Publish Status: Draft'
        expect(page).to have_content 'Publish status was changed to draft.'
      end
    end
  end

  describe 'draft grant', js: true do
    before(:each) do
      @draft_grant     = create(:draft_grant_with_users_and_questions)
      @admin_user      = @draft_grant.grant_users.grant_role_admin.first.user
      @editor_user     = @draft_grant.grant_users.grant_role_editor.first.user
    end

    context 'grant admin user' do
      before(:each) do
        login_as(@admin_user)
        visit edit_grant_path(@draft_grant)
      end

      scenario 'current status and change status button are shown' do
        expect(page).to have_content 'Current Publish Status: Draft'
        expect(page).to have_selector(:link_or_button, 'Publish this Grant')
      end

      scenario 'can change status to published' do
        click_button 'Publish this Grant'
        expect(page).to have_content 'Current Publish Status: Published'
        expect(page).to have_content 'Publish status was changed to published.'
      end

      pending 'failure' do
        fail 'add failed status change'
        click_button 'Publish this Grant'
        expect(@draft_grant).to receive(:update).and_return false
        expect(page).to have_content 'Current Publish Status: Draft'
      end
    end

    context 'grant editor user' do
      before(:each) do
        login_as(@editor_user)
        visit edit_grant_path(@draft_grant)
      end

      scenario 'current status and change status button are shown' do
        expect(page).to have_content 'Current Publish Status: Draft'
        expect(page).to have_selector(:link_or_button, 'Publish this Grant')
      end

      scenario 'can change status to draft' do
        click_button 'Publish this Grant'
        expect(page).to have_content 'Current Publish Status: Published'
        expect(page).to have_content 'Publish status was changed to published.'
      end
    end
  end
end
