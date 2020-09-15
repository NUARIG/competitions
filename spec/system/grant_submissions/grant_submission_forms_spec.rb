require 'rails_helper'

RSpec.describe 'GrantSubmission::Forms', type: :system do
  add_question_text = 'Add a Question to this Section'
  add_section_text  = 'Add a Section'

  describe 'Draft Grant Edit form', js: true do
    before(:each) do
      @draft_grant = create(:draft_grant_with_users) # includes one question
      @form        = @draft_grant.form
      @original_first_question  = @draft_grant.questions.find_by(display_order: 1)
      @original_second_question = @draft_grant.questions.find_by(display_order: 2)
      @original_third_question  = @draft_grant.questions.find_by(display_order: 3)
      @admin  = @draft_grant.grant_permissions.role_admin.first.user
      @editor = @draft_grant.grant_permissions.role_editor.first.user
      @viewer = @draft_grant.grant_permissions.role_viewer.first.user
    end

    context 'grant admin' do
      before(:each) do
        login_as(@admin, scope: :saml_user)
        visit edit_grant_form_path(@draft_grant, @form)
      end

      scenario 'has edit links' do
        expect(page).to have_link add_section_text
        expect(page).to have_button 'Save'
      end

      scenario 'has enabled inputs' do
        expect(page).not_to have_field 'Section Title', disabled: true
        expect(page).not_to have_field 'Question Text', disabled: true
        expect(page).not_to have_field 'Required', disabled: true
        expect(page).not_to have_field 'Help Text', disabled: true
      end

      context 'section' do
        scenario 'can be added to a form' do
          expect do
            new_section_text = Faker::Lorem.sentence
            click_link add_section_text
            find_field('Title', with: '').set(new_section_text)
            click_button 'Save'
          end.to (change{@draft_grant.form.sections.count}).by 1
          expect(page).to have_text 'Submission Form successfully updated'
        end

        scenario 'display_order is updated on delete' do
          original_section = @draft_grant.form.sections.first
          expect(original_section.display_order).to be 1
          find('.delete-section').click
          click_link add_section_text
          new_section_text = Faker::Lorem.sentence
          find_field('Title', with: '').set(new_section_text)
          click_button 'Save'
          expect(@draft_grant.form.sections.first.display_order).not_to be 2
          expect(@draft_grant.form.sections.first.display_order).to be 1
        end

        scenario 'display_order is updated when section in middle of form is deleted' do
          original_first_section = @draft_grant.form.sections.first
          click_link add_section_text
          find_field('Title', with: '').set('Section to be deleted')
          click_link add_section_text
          find_field('Title', with: '').set('Section Last')
          click_button 'Save'
          original_section_section = @draft_grant.form.sections.second
          original_last_section    = @draft_grant.form.sections.last
          page.find("#delete-section-#{original_section_section.id}").click
          click_button 'Save'
          expect(@draft_grant.form.sections.count).to be 2
          expect(GrantSubmission::Section.find(original_first_section.id).display_order).to be 1
          expect(GrantSubmission::Section.find(original_last_section.id).display_order).to be 2
        end
      end

      context 'question' do
        scenario 'display_order is updated on delete' do
          page.find("#delete-question-#{@original_first_question.id}").click
          click_button 'Save'
          expect(@draft_grant.questions.all?{ |q| q.display_order <= 2 })
          expect(GrantSubmission::Question.find(@original_second_question.id).display_order).to be 1
          expect(GrantSubmission::Question.find(@original_third_question.id).display_order).to be 2
        end

        scenario 'display_order is updated when question in middle of form is deleted' do
          expect(@original_first_question.display_order).to be 1
          expect(@original_third_question.display_order).to be 3
          page.find("#delete-question-#{@original_second_question.id}").click
          click_button 'Save'
          expect(@draft_grant.questions.all?{ |q| q.display_order <= 2 })
          expect(GrantSubmission::Question.find(@original_first_question.id).display_order).to be 1
          expect(GrantSubmission::Question.find(@original_third_question.id).display_order).to be 2
        end

        scenario 'display_order is re-set on add' do
          click_link 'Add a Question to this Section'
          new_question_text = Faker::Lorem.sentence
          find_field('Question Text', with: '').set(new_question_text)
          find_field('Question Type', with: '').select('Number')
          click_button 'Save'
          expect(@draft_grant.questions.all?{|q| q.display_order <= 4})
          expect(GrantSubmission::Question.find(@original_first_question.id).display_order).to be 1
          expect(GrantSubmission::Question.find(@original_third_question.id).display_order).to be 3
        end
      end
    end

    context 'grant viewer' do
      before(:each) do
        login_as(@viewer, scope: :saml_user)
        visit edit_grant_form_path(@draft_grant, @form)
      end

      scenario 'has edit links' do
        expect(page).not_to have_link add_section_text
        expect(page).not_to have_button 'Save'
      end

      scenario 'has disabled inputs' do
        expect(page).to have_field 'Section Title', disabled: true
        expect(page).to have_field 'Question Text', disabled: true
        expect(page).to have_field 'Required', disabled: true
        expect(page).to have_field 'Help Text', disabled: true
      end
    end
  end

  describe 'Published Grant with submissions Edit form', js: true do
    before(:each) do
      @open_grant = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
      login_as(@open_grant.grant_permissions.role_admin.first.user, scope: :saml_user)
      visit edit_grant_form_path(@open_grant, @open_grant.form)
    end

    scenario 'does not have edit links' do
      expect(page).to have_text 'This grant has received submissions. To edit this form, please delete all existing submissions'
      expect(page).not_to have_link add_section_text
      expect(page).not_to have_button 'Save'
    end
  end

  describe 'Published Grant without submissions Edit form', js: true do
    before(:each) do
      @published_grant = create(:published_open_grant_with_users)
      login_as(@published_grant.grant_permissions.role_admin.first.user, scope: :saml_user)
      visit edit_grant_form_path(@published_grant, @published_grant.form)
    end

    scenario 'has edit links' do
      expect(page).not_to have_link add_section_text
      expect(page).not_to have_button 'Save'
    end
  end
end
