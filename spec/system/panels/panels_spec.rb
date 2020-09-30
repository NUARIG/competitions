require 'rails_helper'

RSpec.describe 'Panels', type: :system, js: true do
  button_text = 'Update Panel Information'

  let(:grant)   { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:admin)   { grant.admins.first  }
  let(:editor)  { grant.editors.first }
  let(:viewer)  { grant.viewers.first }

  describe 'Edit' do
    context 'user' do
      context 'with grant_permission' do
        context 'grant_admin' do
          before(:each) do
            login_as admin, scope: admin.type.underscore.to_sym
            visit edit_grant_panel_path(grant)
          end

          scenario 'can visit the edit page' do
            expect(page).not_to have_content 'You are not authorized to perform this action.'
          end
        end

        context 'grant_editor' do
          before(:each) do
            login_as editor, scope: editor.type.underscore.to_sym
            visit edit_grant_panel_path(grant)
          end

          scenario 'can visit the edit page' do
            expect(page).not_to have_content 'You are not authorized to perform this action.'
          end
        end

        context 'grant_viewer' do
          before(:each) do
            login_as viewer, scope: viewer.type.underscore.to_sym
            visit edit_grant_panel_path(grant)
          end

          scenario 'cannot visit the edit page' do
            expect(page).to have_content 'You are not authorized to perform this action.'
          end
        end

      end
    end
  end

  describe 'Update' do
    context 'user' do
      context 'with grant_permission' do
        context 'grant_admin' do
          before(:each) do
            login_as admin, scope: admin.type.underscore.to_sym
            visit edit_grant_panel_path(grant)
          end

          scenario 'may update' do
            new_address = Faker::Address.full_address
            page.fill_in 'Meeting Location', with: new_address, fill_options: { clear: :backspace }
            click_button button_text
            expect(page).to have_content 'Panel information successfully updated.'
            expect(grant.panel.meeting_location).to eql new_address
          end
        end

        context 'grant_editor' do
          before(:each) do
            login_as editor, scope: editor.type.underscore.to_sym
            visit edit_grant_panel_path(grant)
          end

          scenario 'may update' do
            new_address = Faker::Address.full_address
            page.fill_in 'Meeting Location', with: new_address, fill_options: { clear: :backspace }
            click_button button_text
            expect(page).to have_content 'Panel information successfully updated.'
            expect(grant.panel.meeting_location).to eql new_address
          end
        end
      end
    end

    context 'paper_trail', versioning: true do
      scenario 'it tracks whodunnit' do
        login_as editor, scope: editor.type.underscore.to_sym
        visit edit_grant_panel_path(grant)
        fill_in 'Meeting Location', with: 'Edited'
        click_button button_text
        expect(grant.panel.versions.last.whodunnit).to eql editor.id
      end
    end
  end
end
