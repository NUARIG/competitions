# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Grants', type: :system do
  describe 'published grant', js: true do
    before(:each) do
      @published_grant = create(:grant_with_users)
      @admin_user      = @published_grant.grant_permissions.role_admin.first.user
      @editor_user     = @published_grant.grant_permissions.role_editor.first.user
      @viewer_user     = @published_grant.grant_permissions.role_viewer.first.user
    end

    context 'grant admin user' do
      before(:each) do
        login_as(@admin_user, scope: :saml_user)
        visit edit_grant_path(@published_grant)
      end

      scenario 'current status and change status button are shown' do
        expect(page).to have_selector '#grant-state .current', text: 'Published'
        # expect(page).to have_content 'Current Publish Status: Published'
        expect(page).to have_link 'Switch to Draft'
      end

      scenario 'can change status to draft' do
        click_link 'Switch to Draft'
        expect(current_path).to eq(edit_grant_path(@published_grant))
        expect(page).to have_selector '#grant-state .current', text: 'Draft'
        # expect(page).to have_content 'Current Publish Status: Draft'
        expect(page).to have_content 'Publish status was changed to draft.'
      end

      scenario 'displays error on failure' do
        allow_any_instance_of(Grant).to receive(:update).and_return(false)
        click_link 'Switch to Draft'
        expect(current_path).to eq(edit_grant_path(@published_grant))
        expect(page).to have_content 'Status change failed. This grant is still in published mode.'
      end
    end

    context 'grant editor user' do
      before(:each) do
        login_as(@editor_user, scope: :saml_user)
        visit edit_grant_path(@published_grant)
      end

      scenario 'current status and change status button are shown' do
        expect(page).to have_selector '#grant-state .current', text: 'Published'
        expect(page).to have_link 'Switch to Draft'
      end

      scenario 'can change status to draft' do
        click_link 'Switch to Draft'
        expect(page).to have_selector '#grant-state .current', text: 'Draft'
        # expect(page).to have_content 'Current Publish Status: Draft'
        expect(page).to have_content 'Publish status was changed to draft.'
      end

      scenario 'displays error on failure' do
        allow_any_instance_of(Grant).to receive(:update).and_return(false)
        click_link 'Switch to Draft'
        expect(page).to have_content 'Status change failed. This grant is still in published mode.'
      end
    end

    context 'grant viewer user' do
      before(:each) do
        login_as(@viewer_user, scope: :saml_user)
        visit edit_grant_path(@published_grant)
      end

      scenario 'current status and change status button are not shown' do
        expect(page).not_to have_selector '#grant-state .current', text: 'Published'
        expect(page).not_to have_link 'Switch to Draft'
      end
    end
  end

  describe 'draft grant', js: true do
    before(:each) do
      @draft_grant     = create(:draft_grant_with_users)
      @admin_user      = @draft_grant.grant_permissions.role_admin.first.user
      @editor_user     = @draft_grant.grant_permissions.role_editor.first.user
    end

    context 'grant admin user' do
      before(:each) do
        login_as(@admin_user, scope: :saml_user)
        visit edit_grant_path(@draft_grant)
      end

      scenario 'current status and change status button are shown' do
        expect(page).to have_selector '#grant-state .current', text: 'Draft'
        expect(page).to have_link 'Publish this Grant'
      end

      scenario 'cannot change status to published without questions' do
        @draft_grant.questions.each { |q| q.destroy! }
        click_link 'Publish this Grant'
        expect(page).to have_selector '#grant-state .current', text: 'Draft'
        expect(page).to have_content 'Status change failed.'
      end

      scenario 'can change status to published with at least one question' do
        click_link 'Publish this Grant'
        expect(current_path).to eq(grant_path(@draft_grant))
        expect(page).to have_content 'Publish status was changed to published'
      end

      scenario 'displays error on failure' do
        allow_any_instance_of(Grant).to receive(:update).and_return(false)
        click_link 'Publish this Grant'
        expect(page).to have_content 'Status change failed. This grant is still in draft mode.'
      end

      scenario 'redirects properly from other error pages' do
        # TODO: Addresses issue #408, but this behavior should be fine-tuned
        visit edit_grant_form_path(@draft_grant, @draft_grant.form)
        click_link 'Add a Section'
        click_button 'Save'
        expect(page).to have_content 'Section Title is required.'
        click_link 'Publish this Grant'
        expect(page).to have_content 'Publish status was changed to published'
      end
    end

    context 'grant editor user' do
      before(:each) do
        login_as(@editor_user, scope: :saml_user)
        visit edit_grant_path(@draft_grant)
      end

      scenario 'current status and change status button are shown' do
        expect(page).to have_selector '#grant-state .current', text: 'Draft'
        # expect(page).to have_content 'Current Publish Status: Draft'
        expect(page).to have_link 'Publish this Grant'
      end

      scenario 'cannot change status to published without question' do
        @draft_grant.questions.each { |q| q.destroy! }
        click_link 'Publish this Grant'
        expect(page).to have_selector '#grant-state .current', text: 'Draft'
        # expect(page).to have_content 'Current Publish Status: Draft'
        expect(page).to have_content 'Status change failed.'
      end

      scenario 'can change status to published with at least one question' do
        click_link 'Publish this Grant'
        expect(current_path).to eq(grant_path(@draft_grant))
        expect(page).to have_content 'Publish status was changed to published'
      end

      scenario 'displays error on failure' do
        allow_any_instance_of(Grant).to receive(:update).and_return(false)
        click_link 'Publish this Grant'
        expect(page).to have_content 'Status change failed. This grant is still in draft mode.'
      end
    end
  end
end
